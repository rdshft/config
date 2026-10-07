{ lib, ... }:
{
  services.picom = {
    enable = true;
    settings = lib.mkForce {
      backend = "glx";
      fading = true;
      fade-delta = 10;
      fade-in-step = 1;
      fade-out-step = 1;
      shadow = false;
      vsync = true;
    };

    extraConfig = ''
      rules = (
        {
          match = "class_g = 'steam' || class_g = 'Steam' || class_g = 'steamwebhelper'";
          fade = false;
          shadow = false;
          full-shadow = false;
          unredir = "forced";
        }
      )
    '';
  };
}
