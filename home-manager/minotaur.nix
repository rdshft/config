{ ... }:
{
  imports = [ ./common.nix ];

  services.ollama = {
    enable = true;
    environmentVariables = {
       HSA_OVERRIDE_GFX_VERSION = "10.3.2";
    };
  };
}
