{ pkgs, ... }:
{
  programs.mpv = {
    enable = true;
    bindings = {
      k = "seek -5";
      j = "seek 5";
      h = "playlist-prev";
      l = "playlist-next";
      m = "cycle mute";
      SPACE = "cycle pause";
      "." = "show-progress";
      "<" = "script-message Cycle_Video_Rotate -90";
      ">" = "script-message Cycle_Video_Rotate 90";
    };
    config = {
      msg-module = true;
      msg-color = true;

      osd-font = "Noto Sans";
      osd-font-size = 15;
      osd-border-size = 2;
      osd-duration = 3500;
      osd-bar-align-x = 0;
      osd-bar-align-y = 1;
      osd-bar-w = 100;
      osd-bar-h = 2;

      user-agent = "Mozilla/5.0";
      hls-bitrate = "max";

      sub-font = "Noto Sans";
      sub-font-size = 36;
      sub-color = "1.0/1.0/1.0/1.0";
      sub-back-color = "0.0/0.0/0.0/0.50";
      sub-border-color = "0.0/0.0/0.0/0.0";
      sub-use-margins = true;
      sub-ass-force-margins = true;
      sub-fix-timing = false;
    };
    scripts = [
      (pkgs.stdenv.mkDerivation {
        pname = "cycle-video-rotate";
        version = "master";

        src = pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/VideoPlayerCode/mpv-tools/refs/heads/master/scripts/cycle-video-rotate.lua";
          sha256 = "sha256-6/6VZIG0qOu8zM6cXqCYzi9/e9RZapeHCcwp+5jWbtA=";
          nativeBuildInputs = [ pkgs.patch ];
          downloadToTemp = true;
          postFetch = ''
            mv "$downloadedFile" cycle-video-rotate.lua
            patch -p1 < ${./mpv/cycle-video-rotate-reset.patch}
            mv cycle-video-rotate.lua "$out"
          '';
        };

        dontUnpack = true;

        installPhase = ''
        runHook preInstall
        mkdir -p $out/share/mpv/scripts
        cp $src $out/share/mpv/scripts/cycle-video-rotate.lua
        runHook postInstall
        '';

        passthru.scriptName = "cycle-video-rotate.lua";
      })
    ];
  };
}
