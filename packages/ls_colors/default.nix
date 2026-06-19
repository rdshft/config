{
  stdenv,
  fetchFromGitHub,
  lib,
}:
stdenv.mkDerivation {
  pname = "LS_COLORS";
  version = "master";

  src = fetchFromGitHub {
    owner = "trapd00r";
    repo = "LS_COLORS";
    rev = "810ce8cac886ac50e75d84fb438b549a1f9478ee";
    hash = "sha256-MMzNknuELhpSkvcPgCL2Pp5A6DZrLajkz8qLphSNbjY=";
  };

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/share
    make generate
    cp lscolors.sh $out/share/
  '';

  meta = {
    description = "A collection of LS_COLORS definitions";
    homepage = "https://github.com/trapd00r/LS_COLORS";
    license = lib.licenses.artistic1;
    platforms = lib.platforms.linux;
  };
}
