{ pkgs, inputs, lib, ... }:

let
  modKey = "Mod4";
  workspace1 = "1";
  workspace2 = "2";
  workspace3 = "3";
  workspace4 = "4";
  workspace5 = "5";
in {
  xsession.windowManager.i3 = {
    enable = true;

    config = {
      modifier = modKey;
      defaultWorkspace = "workspace \"${workspace1}\"";

      floating.modifier = modKey;

      focus = {
        followMouse = false;
        wrapping = "force";
      };

      window = {
        border = 2;
        titlebar = false;
        commands = [
          {
            command = "border pixel 2";
            criteria = {
              instance = "^ghostty$";
            };
          }
        ];
      };

      assigns = {
        "${workspace5}" = [{ class = "^Mullvad VPN$"; }];
      };

      colors = {
        focused = rec {
          border = "#80a0ff"; # https://github.com/bluz71/vim-moonfly-colors/blob/4f7d18cb471ede7407dd966c7563868cae7f4f99/lua/moonfly/init.lua#L38
          childBorder = border;
          indicator = border;
          background = "#000000";
          text = "#ffffff";
        };
      };

      fonts = {
        names = [ "monospace" ];
        size = 11.0;
      };

      gaps = {
        left = 10;
        right = 10;
        top = 4;
        bottom = 4;
        inner = 4;
      };

      keybindings = let
        inherit (lib) splitString;
        inherit (builtins) toString;

        scrot = inputs.self.packages.x86_64-linux.local-scripts.scrot;

        # Turn string to list via "\n" then join with spaces using toString
        toSingleLine = s: toString (splitString "\n" s);

        programLauncher = toSingleLine ''
          exec --no-startup-id ${pkgs.bemenu}/bin/bemenu-run
          --center
          --width-factor 0.2
          --list 20
          --no-spacing
          --no-cursor
          --no-touch
          --ignorecase
          --border 2
          --margin 20
          --counter always
          --prompt 'open'
          --cw 1
          --fn 'Liberation Mono 11'
          '';
      in {
        "${modKey}+r" = "exec --no-startup-id ${pkgs.i3}/bin/i3-msg restart && ${pkgs.polybar}/bin/polybar-msg cmd restart";
        "${modKey}+Return" = "exec ${pkgs.ghostty}/bin/ghostty";
        "${modKey}+w" = "kill";
        "${modKey}+d" = programLauncher;
        "${modKey}+s" = "exec --no-startup-id ${scrot}/bin/scrot";
        "${modKey}+Delete" = "exec --no-startup-id systemctl suspend";

        "${modKey}+h" = "focus left";
        "${modKey}+Shift+h" = "move left";

        "${modKey}+j" = "focus down";
        "${modKey}+Shift+j" = "move down";

        "${modKey}+k" = "focus up";
        "${modKey}+Shift+k" = "move up";

        "${modKey}+l" = "focus right";
        "${modKey}+Shift+l" = "move right";

        "${modKey}+f" = "fullscreen toggle";
        "${modKey}+space" = "floating toggle";
        "${modKey}+1" = "workspace \"${workspace1}\"";
        "${modKey}+2" = "workspace \"${workspace2}\"";
        "${modKey}+3" = "workspace \"${workspace3}\"";
        "${modKey}+4" = "workspace \"${workspace4}\"";
        "${modKey}+5" = "workspace \"${workspace5}\"";
        "${modKey}+6" = "workspace back_and_forth";
        "${modKey}+Shift+1" = "move container to workspace number \"${workspace1}\"; workspace \"${workspace1}\"";
        "${modKey}+Shift+2" = "move container to workspace number \"${workspace2}\"; workspace \"${workspace2}\"";
        "${modKey}+Shift+3" = "move container to workspace number \"${workspace3}\"; workspace \"${workspace3}\"";
        "${modKey}+Shift+4" = "move container to workspace number \"${workspace4}\"; workspace \"${workspace4}\"";
        "${modKey}+Shift+5" = "move container to workspace number \"${workspace5}\"; workspace \"${workspace5}\"";
      };

      bars = [
        {
          command = "${pkgs.polybar}/bin/polybar";
          position = "top";
          workspaceButtons = true;
          workspaceNumbers = true;
        }
      ];

      startup = [
        { command = "${pkgs.dunst}/bin/dunst"; }
        { command = "${pkgs.polybar}/bin/polybar"; }
        { command = "${pkgs.networkmanagerapplet}/bin/nm-applet"; }
        {
          command = "${pkgs.mullvad-vpn}/bin/mullvad-vpn";
          notification = false;
        }
      ];
    };
  };
}
