{...}: {
  flake.modules.nixos.portals = {pkgs, ...}: {
    environment.systemPackages = [pkgs.xdg-utils];

    xdg.portal = {
      enable = true;

      extraPortals = [pkgs.xdg-desktop-portal-gtk pkgs.xdg-desktop-portal-wlr];

      config = {
        common.default = ["gtk"];
        niri = {
          default = ["gtk" "wlr"];
          "org.freedesktop.impl.portal.Screenshot" = ["wlr"];
          "org.freedesktop.impl.portal.ScreenCast" = ["wlr"];
          "org.freedesktop.impl.portal.FileChooser" = ["gtk"];
        };
      };

      wlr = {
        enable = true;
        settings.screencast = {
          chooser_type = "simple";
          chooser_cmd = "${pkgs.slurp}/bin/slurp -f %o -or";
        };
      };
    };
  };
}
