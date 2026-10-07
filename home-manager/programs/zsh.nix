{ inputs, pkgs, config, ... }:
{
  programs.zsh = let
    LS_COLORS = inputs.self.packages.x86_64-linux.LS_COLORS;
    fts = inputs.self.packages.x86_64-linux.fts;
  in {
    enable = true;

    autosuggestion.enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    enableVteIntegration = true;

    dotDir = "${config.xdg.configHome}/zsh";

    # https://unix.stackexchange.com/a/71258

    initContent = ''
      PS1="%B%F{#cccccc}%n%f%b@%F{magenta}%m%f %B%F{blue}%c%f%b %# "

      export BROWSER="librewolf"
      export TERMINAL="ghostty"
      export MANPAGER="nvim +Man!"
      export MANWIDTH=80

      export FZF_DEFAULT_OPTS="--height=20 --layout=reverse"

      HISTFILE="$HOME/.zsh_history"
      HISTSIZE=10000000
      SAVEHIST=10000000

      autoload -Uz compinit up-line-or-beginning-search down-line-or-beginning-search
      compinit

      zle -N up-line-or-beginning-search
      zle -N down-line-or-beginning-search

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

      zstyle ':completion:*' file-patterns '.*' '*'
      zstyle ':completion:*:*:cd:*' file-patterns '*/' '.*(/)'

      # Case-insensitive completion
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

      # Show descriptions for completions
      zstyle ':completion:*' format '%F{yellow}-- %d --%f'

      # Group completions by type
      zstyle ':completion:*' group-name ''''''

      # Use caching for faster completion
      zstyle ':completion:*' use-cache on
      zstyle ':completion:*' cache-path ~/.zcache

      bindkey "^[OA" up-line-or-beginning-search
      bindkey "^[OB" down-line-or-beginning-search
      bindkey "^[[A" up-line-or-beginning-search
      bindkey "^[[B" down-line-or-beginning-search

      bindkey '^I' complete-word
      bindkey '^A' beginning-of-line
      bindkey '^E' end-of-line
      bindkey '^Y' autosuggest-accept
      bindkey -r "^F"

      function fcd() {
          cd "$(bfs $HOME -type d -nocolor 2>/dev/null | fzf --scheme=path --preview='lsd -lhF --group-dirs first --date relative {} --color always')"
          zle reset-prompt
      }
      zle -N fuzzy_cd fcd
      bindkey "^f" fuzzy_cd

      ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(up-line-or-beginning-search down-line-or-beginning-search)
      source ${LS_COLORS}/share/lscolors.sh
      '';

    shellAliases = {
      grep = "grep --color=auto";
      lsblk = "lsblk -o \"NAME,FSTYPE,FSAVAIL,FSUSE%,SIZE,TYPE,MOUNTPOINT\" -p";
      ls = "lsd -lh"; # apparently these 2 options cannot be added to the config file
      cat = "bat --pager=never --style \"header,numbers\"";
      mkdir = "mkdir -pv";
      cp = "cp -iv";
      mv = "mv -iv";
      rm = "rm -Iv";

      fts = "${fts}/bin/fts";
    };
  };
}
