{ pkgs, inputs, ... }:
{
  programs.home-manager.enable = true;

  # TODO: make a tree import function
  imports = [
    ./programs/alacritty
    ./programs/easyeffects
    ./programs/i3
    ./programs/neovim
    ./programs/polybar
    ./programs/quickshell

    ./programs/audio.nix
    ./programs/bat.nix
    ./programs/browsers.nix
    ./programs/dunst.nix
    ./programs/feh.nix
    ./programs/fonts.nix
    ./programs/fzf.nix
    ./programs/gaming.nix
    ./programs/ghostty.nix
    ./programs/git.nix
    ./programs/gtk.nix
    ./programs/lsd.nix
    ./programs/mpd.nix
    ./programs/mpv.nix
    ./programs/newsboat.nix
    ./programs/picom.nix
    ./programs/tmux.nix
    ./programs/vpn.nix
    ./programs/x11.nix
    ./programs/xdg.nix
    ./programs/zathura.nix
    ./programs/zsh.nix
  ];

  home = {
    username = "sean";
    homeDirectory = "/home/sean";
    stateVersion = "23.11";

    packages = (builtins.attrValues {
      inherit (pkgs)
      ripgrep
      bfs
      htop
      yt-dlp
      pet
      jq
      file
      unzip
      wget
      ffmpeg
      thunderbird
      transmission_4-gtk
      mediainfo
      fastfetch
      tokei
      moor
      xkill
      tenacity
      grok-build;
    });
  };

  xdg.userDirs.setSessionVariables = true;

  manual.html.enable = false;
  manual.manpages.enable = false;
  manual.json.enable = false;

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  services.ollama = {
    enable = true;
    environmentVariables = {
       HSA_OVERRIDE_GFX_VERSION = "10.3.2";
    };
  };
}
