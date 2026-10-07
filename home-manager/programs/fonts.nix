{ pkgs, ... }:
{
  home.packages = builtins.attrValues {
    inherit (pkgs)
      cantarell-fonts
      public-sans
      liberation_ttf
      terminus_font
      dejavu_fonts
      noto-fonts
      fantasque-sans-mono
      rubik
    ;
  };
}
