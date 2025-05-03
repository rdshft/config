-- yet another git wrapper

local function get_git_status()
    vim.system({
        "git",
        "status",
        "-s"
    }, { text = true }, function(obj)
        files_status = vim.split(obj.stdout, "\n")
    end):wait()

    vim.system({
        "git",
        "log",
        "origin/master..HEAD",
        "--oneline",
        "--pretty=format:%t %s (%ar)"
    }, { text = true }, function(obj)
        if obj.stdout == "" then
            unpushed_commits = vim.split(obj.stdout, "\n")
        else
            unpushed_commits = {}
        end
    end):wait()

    local current_branch = vim.system({
        "git",
        "branch",
        "--show-current",
    }, { text = true }):wait().stdout

    local branch = string.gsub(current_branch, "\n", "")

    local old_git_status = {
        branch = branch,
        files = {
            unstaged = {},
            staged = {},
            untracked = {},
            deleted = {},
        },
        unpushed_commits = unpushed_commits,
    }

    for _, v in ipairs(files_status) do
        if v then
            local file = vim.split(v, " ")
            if file[1] == "" then
                if file[2] == "M" then
                    table.insert(old_git_status["files"]["unstaged"], file[3])
                end
            elseif file[1] == "M" then
                table.insert(old_git_status["files"]["staged"], file[3])
            elseif file[1] == "D" then
                table.insert(old_git_status["files"]["deleted"], file[3])
            elseif file[1] == "??" then
                table.insert(old_git_status["files"]["untracked"], file[2])
            elseif file[1] == "AM" then
                table.insert(old_git_status["files"]["staged"], file[2])
            elseif file[1] == "A" then
                table.insert(old_git_status["files"]["staged"], file[3])
            end
        end
    end

    return old_git_status
end

local function get_git_status_pretty()
    local old_git_status = get_git_status()

    local pretty_status_header = { "Branch: " .. old_git_status["branch"], "" }
    local pretty_status_staged = { "Staged (" .. #old_git_status["files"]["staged"] .. ")", "" }
    local pretty_status_unstaged = { "Unstaged (" .. #old_git_status["files"]["unstaged"] .. ")", "" }
    local pretty_status_untracked = { "Untracked (" .. #old_git_status["files"]["untracked"] .. ")", "" }
    local pretty_status_unpushed = { "Unpushed Commits (" .. #old_git_status["unpushed_commits"] .. ")", "" }

    for _, v in ipairs(old_git_status["files"]["staged"]) do
        table.insert(pretty_status_staged, 2, v)
    end

    for _, v in ipairs(old_git_status["files"]["unstaged"]) do
        table.insert(pretty_status_unstaged, 2, v)
    end

    for _, v in ipairs(old_git_status["unpushed_commits"]) do
        table.insert(pretty_status_unpushed, 2, v)
    end

    for _, v in ipairs(old_git_status["files"]["untracked"]) do
        table.insert(pretty_status_untracked, 2, v)
    end

    local old_git_status_pretty = vim.tbl_flatten({
        pretty_status_header,
        pretty_status_staged,
        pretty_status_unstaged,
        pretty_status_untracked,
        pretty_status_unpushed,
    })

    return old_git_status_pretty
end

local function get_win_git_status()
    local buffer = vim.api.nvim_create_buf(true, true) -- create scratch buffer

    vim.api.nvim_buf_set_var(buffer, "modifiable", false)

    local column_count = vim.opt.columns._value
    local line_count = vim.opt.lines._value

    -- how far along from the left we want the window to be
    local x = column_count / 5 -- don't ask me what 5 is for; it just looks nice in the TUI when I put 5 here
    local width = math.floor(column_count - (x * 2))

    -- how far down from the top we want the window to be
    local y = line_count / 5
    local height = math.floor(line_count - (y * 2))

    local old_git_status = get_git_status_pretty()
    vim.api.nvim_buf_set_lines(buffer, 0, -1, true, old_git_status)

    local window_opts = {
        relative = "editor",
        width = width,
        height = height,
        col = x,
        row = y,
        anchor = "NW",
        border = "rounded",
        title = " Git Status ",
        title_pos = "center",
    }

    vim.api.nvim_set_option_value("modifiable", false, { buf = buffer })

    return buffer, vim.api.nvim_open_win(buffer, true, window_opts)
end

local function redraw_git_status(buf)
    local status = get_git_status_pretty()
    vim.api.nvim_set_option_value("modifiable", true, { buf = buf })
    vim.api.nvim_buf_set_lines(buf, 0, -1, true, status)
    vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
end

local function get_current_file()
    local current_line = vim.api.nvim_get_current_line()
    local line_split = vim.split(current_line, "\n")

    return line_split[#line_split]
end

local function get_old_git_status(file)

    local old_status = get_git_status()

    for k,v in pairs(old_status["files"]) do
        for _,f in pairs(v) do
            if f == file then
                return k
            end
        end
    end
end

vim.keymap.set("n", "<leader>gs",
    function()
        git_buf, git_win = get_win_git_status()
    end)

-- toggle stage/unstage
vim.keymap.set("n", "L",
    function()
        local file = get_current_file()
        local old_status = get_old_git_status(file)

        if old_status == "staged" then
            vim.system({ "git", "restore", "--staged", file }):wait()
        else
            vim.system({ "git", "add", file }):wait()
        end

        redraw_git_status(git_buf)
    end,
    { buffer = git_buf }
)
