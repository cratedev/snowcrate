{
  config,
  lib,
  namespace,
  inputs,
  pkgs,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.desktop.niri;
in {
  options.${namespace}.desktop.niri = with types; {
    enable = mkBoolOpt false "Whether or not to enable niri.";
  };

  imports = [inputs.niri.nixosModules.niri];

  config = mkMerge [
    # Always apply the overlay (unconditional)
    {
      nixpkgs.overlays = [inputs.niri.overlays.niri];
    }

    # Always disable the cache mechanism
    {
      niri-flake.cache.enable = false;
      programs.niri.enable = mkDefault false;
    }

    # Only enable niri when our option is true
    (mkIf cfg.enable {
      programs.niri = {
        enable = true;
        package = inputs.niri.packages.${pkgs.system}.niri-unstable;
      };
      programs.uwsm = {
        enable = true;
        waylandCompositors = {
          niri = {
            prettyName = "niri";
            comment = "Niri compositor managed by UWSM";
            binPath = "/run/current-system/sw/bin/niri-session";
          };
        };
      };
    })
  ];
}
