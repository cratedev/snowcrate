{
  crate = {
    profiles.desktop.enable = true;
    desktop.niri.outputs = {
      "HDMI-A-1" = {
        mode = {
          width = 3840;
          height = 2160;
          refresh = 120.0;
        };
        scale = 1.0;
      };
    };
  };

  home.stateVersion = "24.05";
}
