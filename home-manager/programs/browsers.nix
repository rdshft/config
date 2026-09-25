{ config, ... }:
{
  programs = {
    firefox.enable = true;
    firefox.configPath = "${config.xdg.configHome}/mozilla/firefox";
    librewolf.enable = true;
  };
}
