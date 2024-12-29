# vim: ft=sh

export BROWSER="firefox"
export TERMINAL="alacritty"
export MANPAGER="nvim +Man!"
export MANWIDTH=80

HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000000
SAVEHIST=10000000

# Further reading: https://martinheinz.dev/blog/110
setopt EXTENDED_HISTORY      # Write the history file in the ':start:elapsed;command' format.
setopt INC_APPEND_HISTORY    # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY         # Share history between all sessions.
setopt HIST_IGNORE_DUPS      # Do not record an event that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS  # Delete an old recorded event if a new event is a duplicate.
setopt HIST_IGNORE_SPACE     # Do not record an event starting with a space.
setopt HIST_SAVE_NO_DUPS     # Do not write a duplicate event to the history file.
setopt HIST_VERIFY           # Do not execute immediately upon history expansion.export
setopt HIST_NO_STORE         # Don't store history commands
setopt HIST_REDUCE_BLANKS    # Remove superfluous blanks from each command line being added to the history.

bindkey "^[[A" up-line-or-search
bindkey "^[[B" down-line-or-search

export FZF_DEFAULT_OPTS="--height=20 --layout=reverse"

# Do prompt stuff down here cause git integration
export PROMPT="%B%F{#ffffff}%n%f%b@%F{magenta}%m%f %B%F{blue}%c%f%b %# "

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
alias ytmp3="yt-dlp -x --extract-audio --audio-format mp3"

function fcd() {
    cd "$(bfs $HOME -type d -nocolor 2>/dev/null | fzf --border)"
}

# Plugins
source /usr/share/zsh/site-functions/zsh-syntax-highlighting.zsh
source /usr/share/zsh/site-functions/zsh-autosuggestions.zsh

# Managed by stow
source ~/.lscolors.sh

eval "$(fzf --zsh)"
