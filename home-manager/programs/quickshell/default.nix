{ pkgs, ... }:
{
  programs.quickshell = {
    enable = true;
    configs.default = ./configs;
    activeConfig = "default";
  };
}
