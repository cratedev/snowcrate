{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.desktop.display-manager.sddm;
  sddmHome = config.users.users.sddm.home;
  user = config.${namespace}.user.name;
in {
  options.${namespace}.desktop.display-manager.sddm = with types; {
    enable = mkBoolOpt false "Whether or not to enable sddm.";
    wayland = mkBoolOpt true "Whether or not to use Wayland.";
    theme = mkOpt str "catppuccin-mocha" "The theme to use.";
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.rules = ["d ${sddmHome}/.config 0711 sddm sddm"];

    environment.systemPackages = with pkgs; [
      (catppuccin-sddm.override {
        flavor = "mocha";
        font = "Noto Sans";
        fontSize = "9";
      })
    ];

    services = {
      displayManager = {
        autoLogin = {
          enable = true;
          user = "${user}";
        };
        sddm = {
          enable = true;
          wayland.enable = cfg.wayland;
          inherit (cfg) theme;
          package = pkgs.kdePackages.sddm;
        };
      };
    };
  };
}
