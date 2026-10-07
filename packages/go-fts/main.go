package main

import (
	"fmt"
	"io/fs"
	"log"
	"os"
	"path/filepath"
	"sort"
	"strings"
	"unicode/utf8"
)

var cwd string
var lsColors = parseLSColors()
var found []fileEntry

type fileEntry struct {
    path string
    ext  string
    size int64
}

type FileType struct {
    Extension  string
    Count      int
    BytesCount int64
    Paths      []string
}

type treeNode struct {
    name     string
    isDir    bool
    children []*treeNode
}

const (
    sizeMB int64 = 1024 * 1024
    sizeGB int64 = 1024 * 1024 * 1024

    kindDir       = "dir"
    kindHiddenDir = ".dir"
    lsdDirIcon    = "\uf115" // 
)

func humanizeUnits(units int64) string {
    unitCombo := 0
    siUnits := []string{"B", "KB", "MB", "GB", "TB"}

    for {
        if units >= 1024 {
            units /= 1024
            unitCombo += 1
        } else {
            break
        }
    }

    return fmt.Sprintf("%d %s", units, siUnits[unitCombo])
}

// lsd size colours (default dark theme):
//   < 1 MiB  -> 229 Wheat1 (small)
//   < 1 GiB  -> 216 LightSalmon1 (medium)
//   >= 1 GiB -> 172 Orange3 (large)
func sizeANSIColor(bytes int64) string {
    switch {
    case bytes >= sizeGB:
        return "172"
    case bytes >= sizeMB:
        return "216"
    default:
        return "229"
    }
}

func colorizeSize(s string, bytes int64) string {
    return fmt.Sprintf("\x1b[38;5;%sm%s\x1b[0m", sizeANSIColor(bytes), s)
}

func parseLSColors() map[string]string {
    colors := make(map[string]string)
    for _, part := range strings.Split(os.Getenv("LS_COLORS"), ":") {
        if part == "" {
            continue
        }
        key, code, ok := strings.Cut(part, "=")
        if !ok || key == "" {
            continue
        }
        colors[key] = code
    }
    return colors
}

func lsColorForExt(ext string) string {
    if code, ok := lsColors["*."+ext]; ok {
        return code
    }
    if code, ok := lsColors["*."+strings.ToLower(ext)]; ok {
        return code
    }
    if code, ok := lsColors["fi"]; ok {
        return code
    }
    return ""
}

func iconForExt(ext string) string {
    if ext == kindDir || ext == kindHiddenDir {
        return lsdDirIcon
    }
    if icon, ok := lsdIcons[strings.ToLower(ext)]; ok {
        return icon
    }
    return lsdDefaultFileIcon
}

func isDirKind(ext string) bool {
    return ext == kindDir || ext == kindHiddenDir
}

func fileTypeLabel(ext string) string {
    label := iconForExt(ext) + " " + ext
    if isDirKind(ext) {
        label += "/"
    }
    return label
}

func colorizeType(ext string) string {
    name := iconForExt(ext) + " " + ext
    colored := colorize(name, colorForKind(ext))
    if isDirKind(ext) {
        return colored + "/"
    }
    return colored
}

func colorForKind(ext string) string {
    if isDirKind(ext) {
        if code, ok := lsColors["di"]; ok {
            return code
        }
        return ""
    }
    return lsColorForExt(ext)
}

func colorize(s, code string) string {
    if code == "" {
        return s
    }
    return fmt.Sprintf("\x1b[%sm%s\x1b[0m", code, s)
}

func padRight(s string, width int) string {
    n := utf8.RuneCountInString(s)
    if n >= width {
        return s
    }
    return s + strings.Repeat(" ", width-n)
}

func entrySize(entry fs.DirEntry) int64 {
    info, err := entry.Info()
    if err != nil {
        log.Fatalf("error: %s\n", err)
    }
    return info.Size()
}

func addFile(relPath string, entry fs.DirEntry) {
    if entry.IsDir() {
        return
    }

    filename := filepath.Base(relPath)
    if strings.HasPrefix(filename, ".") {
        return
    }

    parts := strings.Split(filename, ".")
    if len(parts) == 1 {
        return
    }

    found = append(found, fileEntry{
        path: relPath,
        ext:  parts[len(parts)-1],
        size: entrySize(entry),
    })
}

func addDir(relPath string, entry fs.DirEntry) {
    kind := kindDir
    if strings.HasPrefix(filepath.Base(relPath), ".") {
        kind = kindHiddenDir
    }

    found = append(found, fileEntry{
        path: relPath,
        ext:  kind,
        size: entrySize(entry),
    })
}

func collectEntry(path string, entry fs.DirEntry, err error) error {
    if err != nil {
        if entry != nil && entry.IsDir() {
            return fs.SkipDir
        }
        return nil
    }

    rel, relErr := filepath.Rel(cwd, path)
    if relErr != nil {
        rel = path
    }

    // Don't count the walk root. Hidden dirs are counted, then not entered.
    hidden := path != cwd && strings.HasPrefix(entry.Name(), ".")
    if entry.IsDir() {
        if path != cwd {
            addDir(rel, entry)
        }
        if hidden {
            return fs.SkipDir
        }
        return nil
    }

    if hidden {
        return nil
    }

    addFile(rel, entry)
    return nil
}

func insertPath(root *treeNode, path string) {
    node := root
    parts := strings.Split(path, string(filepath.Separator))
    for i, part := range parts {
        if part == "" || part == "." {
            continue
        }
        last := i == len(parts)-1
        var child *treeNode
        for _, c := range node.children {
            if c.name == part {
                child = c
                break
            }
        }
        if child == nil {
            child = &treeNode{name: part, isDir: !last}
            node.children = append(node.children, child)
        }
        node = child
    }
}

func sortTree(node *treeNode) {
    sort.Slice(node.children, func(i, j int) bool {
        return node.children[i].name < node.children[j].name
    })
    for _, child := range node.children {
        sortTree(child)
    }
}

func buildTree(paths []string) *treeNode {
    root := &treeNode{name: ".", isDir: true}
    for _, path := range paths {
        insertPath(root, path)
    }
    sortTree(root)
    return root
}

func printTree(nodes []*treeNode, prefix, ext string) {
    for i, node := range nodes {
        last := i == len(nodes)-1
        connector := "├── "
        nextPrefix := prefix + "│   "
        if last {
            connector = "└── "
            nextPrefix = prefix + "    "
        }

        label := node.name
        if node.isDir || isDirKind(ext) {
            label = colorize(node.name, colorForKind(kindDir)) + "/"
        } else {
            label = colorize(label, lsColorForExt(ext))
        }
        fmt.Printf("%s%s%s\n", prefix, connector, label)

        if len(node.children) > 0 {
            printTree(node.children, nextPrefix, ext)
        }
    }
}

func printHelp() {
    name := filepath.Base(os.Args[0])
    fmt.Printf("Usage: %s [-r] [-s] [-t]\n\n", name)
    fmt.Println("Count files and directories in the current directory.")
    fmt.Println()
    fmt.Println("  -r          search recursively")
    fmt.Println("  -s          sort by size instead of count")
    fmt.Println("  -t          tree of files under each type")
    fmt.Println("  -h, --help  show this help")
}

func main() {
    var err error

    recursive := false
    sortBySize := false
    treeView := false
    for _, arg := range os.Args[1:] {
        switch arg {
        case "-r":
            recursive = true
        case "-s":
            sortBySize = true
        case "-t":
            treeView = true
        case "-h", "--help":
            printHelp()
            return
        }
    }

    cwd, err = os.Getwd()

    if err != nil {
        log.Fatalln("error: ", err)
    }

    if recursive {
        err = filepath.WalkDir(cwd, collectEntry)
        if err != nil {
            log.Fatalln("error: ", err)
        }
    } else {
        dirents, readErr := os.ReadDir(cwd)
        if readErr != nil {
            log.Fatalln("error: ", readErr)
        }
        for _, f := range dirents {
            if f.IsDir() {
                addDir(f.Name(), f)
                continue
            }
            addFile(f.Name(), f)
        }
    }

    fileTypes := make([]FileType, 0)

    var fileCount int
    var allBytesCount int64

    for _, f := range found {
        fileCount += 1
        size := f.size
        if isDirKind(f.ext) {
            size = 0
        } else {
            allBytesCount += f.size
        }

        isFound := false
        for n, v := range fileTypes {
            if f.ext == v.Extension {
                fileTypes[n].Count += 1
                fileTypes[n].BytesCount += size
                fileTypes[n].Paths = append(fileTypes[n].Paths, f.path)
                isFound = true
                break
            }
        }

        if !isFound {
            fileTypes = append(fileTypes, FileType{
                Extension:  f.ext,
                Count:      1,
                BytesCount: size,
                Paths:      []string{f.path},
            })
        }
    }

    sort.Slice(fileTypes, func(i, j int) bool {
        if sortBySize {
            return fileTypes[i].BytesCount > fileTypes[j].BytesCount
        }
        return fileTypes[i].Count > fileTypes[j].Count
    })

    fmt.Printf("Total: %d", fileCount)
    fmt.Printf(" (%s)\n", colorizeSize(humanizeUnits(allBytesCount), allBytesCount))

    typeHeader := "File type"
    countHeader := "Count"
    sizeHeader := "Total culminative size"

    typeWidth := utf8.RuneCountInString(typeHeader)
    countWidth := utf8.RuneCountInString(countHeader)
    for _, v := range fileTypes {
        if w := utf8.RuneCountInString(fileTypeLabel(v.Extension)); w > typeWidth {
            typeWidth = w
        }
        if w := utf8.RuneCountInString(fmt.Sprintf("%d", v.Count)); w > countWidth {
            countWidth = w
        }
    }

    if !treeView {
        fmt.Printf("%s  %s  %s\n",
            padRight(typeHeader, typeWidth),
            padRight(countHeader, countWidth),
            sizeHeader,
        )
    }

    for _, v := range fileTypes {
        label := fileTypeLabel(v.Extension)
        pad := typeWidth - utf8.RuneCountInString(label)
        if pad < 0 {
            pad = 0
        }
        coloredType := colorizeType(v.Extension)
        count := padRight(fmt.Sprintf("%d", v.Count), countWidth)
        size := ""
        if !isDirKind(v.Extension) {
            size = colorizeSize(humanizeUnits(v.BytesCount), v.BytesCount)
        }
        fmt.Printf("%s%s  %s  %s\n", coloredType, strings.Repeat(" ", pad), count, size)

        if treeView {
            root := buildTree(v.Paths)
            printTree(root.children, "", v.Extension)
        }
    }
}
