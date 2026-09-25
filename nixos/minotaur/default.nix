{ pkgs, lib, ... }:
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
        configurationLimit = 5;
      };
      efi.canTouchEfiVariables = true;
      timeout = 5;
    };
    kernelPackages = pkgs.linuxPackages_zen;
  };

  # Stop the NIC going into power saving mode and dropping the connection while
  # visibly still connected.
  boot.extraModprobeConfig = ''
    options rtw89_core disable_ps_mode=y
    options rtw89_pci disable_aspm_l1=y disable_aspm_l1ss=y
  '';

  networking.networkmanager.wifi.powersave = false;

  networking = {
    hostName = "minotaur";
    networkmanager.enable = true;
  };

  # Needed for doas to be able to use git via root user when using nixos-rebuild
  environment.systemPackages = with pkgs; [ git ];

  programs = {
    steam.enable = true;
    gamemode.enable = true;
  };

  programs.virt-manager.enable = true;
  virtualisation.libvirtd.enable = true;

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "spotify" ];

  environment.pathsToLink = [ "/share/applications" "/share/xdg-desktop-portal" ];

  system.stateVersion = "23.11";
}
