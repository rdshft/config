{
  services.picom = {
    enable = true;
    backend = "glx";
    fade = true;
    fadeSteps = [ 1 1 ];
    inactiveOpacity = 1;
    activeOpacity = 1;
    shadow = false;
    vSync = true;

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
