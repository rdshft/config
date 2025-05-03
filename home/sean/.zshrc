# vim: ft=sh

export BROWSER="librewolf"
export TERMINAL="ghostty"
export MANPAGER="nvim +Man!"
export MANWIDTH=80

HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000000
SAVEHIST=10000000

autoload -U compinit
compinit

setopt extended_history      # Write the history file in the ':start:elapsed;command' format.
setopt inc_append_history    # Write to the history file immediately, not when the shell exits.
setopt share_history         # Share history between all sessions.
setopt hist_ignore_dups      # Do not record an event that was just recorded again.
setopt hist_ignore_all_dups  # Delete an old recorded event if a new event is a duplicate.
setopt hist_ignore_space     # Do not record an event starting with a space.
setopt hist_save_no_dups     # Do not write a duplicate event to the history file.
setopt hist_verify           # Do not execute immediately upon history expansion.export
setopt hist_no_store         # Don't store history commands
setopt hist_reduce_blanks    # Remove superfluous blanks from each command line being added to the history.
setopt globdots
setopt extendedglob

# Tab complete hidden files
zstyle ':completion:*' file-patterns '.*' '*'
# cd tab complete directories only (should be default behaviour if you ask me)
zstyle ':completion:*:*:cd:*' file-patterns '*/' '.*(/)'

bindkey "^[[A" up-line-or-search
bindkey "^[[B" down-line-or-search

export FZF_DEFAULT_OPTS="--height=20 --layout=reverse"

function colour_exit_code() {
    local exit_code=$?
    if (( exit_code > 0 )); then
        # Bold red for exit codes greater than 0
        echo "%B%F{red}$exit_code%f%b "
    fi
}

function get_git_branch() {
    local branch_name
    if [[ -d ".git/" ]]; then
        branch_name=$(git branch --show-current)
        echo "%B%F{red}(git:$branch_name)%f%b "
    else
        echo
    fi
}

# needs this function so the above functions can run or else only the
# condition runs fine but the prompt will not change
precmd(){
    PS1="$(colour_exit_code)%B%F{#cccccc}%n%f%b@%F{magenta}%m%f %B%F{blue}%c%f%b $(get_git_branch)%# "
}

path+=('/home/sean/.local/bin')

bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
bindkey '^Y' autosuggest-accept

alias grep="grep --color=auto"
alias lsblk="lsblk -o \"NAME,FSTYPE,FSAVAIL,FSUSE%,SIZE,TYPE,MOUNTPOINT\" -p"
alias ls="lsd -lhF --group-dirs first --date relative"
alias cat="bat --pager=never"
alias mkdir="mkdir -pv"
alias cp="cp -iv"
alias mv="mv -iv"
alias rm="rm -Iv"
alias soda="ssh -p 52222 num@soda.privatevoid.net"
alias ncdu="ncdu --color off"
alias ytdl="yt-dlp"
alias ytba="yt-dlp -f bestaudio"

function fcd() {
    cd "$(bfs $HOME -type d -nocolor 2>/dev/null | fzf --scheme=path --preview='lsd -lhF --group-dirs first --date relative {} --color always')"
    zle reset-prompt
}
zle -N fuzzy_cd fcd
bindkey "^f" fuzzy_cd

# Plugins
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# Managed by stow
source ~/.lscolors.sh

eval "$(fzf --zsh)"
