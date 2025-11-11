{
  crate = {
    profiles.laptop.enable = true;
    desktop.niri.outputs = {
      "eDP-1" = {
        mode = {
          width = 1920;
          height = 1200;
          refresh = 60.0;
        };
        scale = 1.0;
      };
    };
  };
  home.stateVersion = "24.05";
}
