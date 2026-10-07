{ pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ./services.nix
    ./../common.nix
    ./../user.nix
  ];

  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        consoleMode = "max";
        editor = false;
        configurationLimit = 20;
      };
      efi.canTouchEfiVariables = true;
      timeout = 5;
    };
  };

  networking = {
    hostName = "ceres";
    networkmanager.enable = true;
    stevenblack.enable = true;
  };

  environment.systemPackages = with pkgs; [ git ];

  environment.pathsToLink = [ "/share/applications" "/share/xdg-desktop-portal" ];

  system.stateVersion = "23.05";
}
