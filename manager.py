import subprocess
import sys

def translate_modification(mod_string):
    changes = []
    for n, char in enumerate(mod_string):
        match n:
            case 0:
                if char == ">":
                    is_new_file = mod_string[n + 2]
                    if is_new_file == "+":
                        changes.append("new file")
                    else:
                        changes.append("contents changed")

                if char == "c":
                    type_of_creation = mod_string[n + 1]
                    if type_of_creation == "f":
                        changes.append("new file")
                    if type_of_creation == "d":
                        changes.append("new directory")
                    if type_of_creation == "L":
                        changes.append("new symlink")
                    if type_of_creation == "D":
                        changes.append("new device")
                    if type_of_creation == "S":
                        changes.append("new special file")
            case 5:
                if char == "p":
                    changes.append("permissions changed")
            case 6:
                if char == "o":
                    changes.append("owner changed")
            case 7:
                if char == "g":
                    changes.append("group changed")

    return ", ".join(changes)

def run_command(command):
    cmd = subprocess.run(command, shell=True, capture_output=True, text=True)
    # TODO: add better stdout,stderr handling
    return cmd

def get_status():
    out = run_command("rsync -anc --out-format='%n,%i' home/sean/ /home/sean").stdout
    changed_lines = out.split("\n")
    for line in changed_lines:
        line = line.split(",")
        if not line[0]:
            continue

        modifications = translate_modification(line[1])
        if not len(modifications) == 0:
            sys.stdout.write(f"{line[0]} \x1b[1m({modifications})\x1b[0m\n")

if len(sys.argv) >= 2:
    match sys.argv[1]:
        case "switchhome":
            pass
        case "switchsys":
            pass
        case "status":
            get_status()
        case _:
            pass
