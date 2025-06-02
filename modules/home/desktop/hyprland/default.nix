{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.desktop.hyprland;
in {
  options.${namespace}.desktop.hyprland = with types; {
    enable = mkBoolOpt false "Whether or not to turn on hyprland config.";
    startup = mkOpt (listOf str) [] "List of commands to run when you login";
    appendConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = ''
        Extra configuration lines to add to bottom of `~/.config/hyprland/hyprland.conf`.
      '';
    };
    prependConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = ''
        Extra configuration lines to add to top of `~/.config/hyprland/hyprland.conf`.
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [gtk3 swww grim slurp];
    home.sessionVariables.NIXOS_OZONE_WL = "1";

    programs.kitty.enable = true; # required for the default Hyprland config

    wayland.windowManager.hyprland = {
      enable = true; # enable Hyprland
    };
  };
}
