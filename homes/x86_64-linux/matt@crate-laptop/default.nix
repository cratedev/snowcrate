{lib, ...}: {
  crate = {
    user = {
      name = "matt";
      fullName = "Matthew Henderson";
      email = "matt@crate.dev";
      hostname = "crate-laptop";
    };
    archetypes.laptop = {
      enable = true;
      display-name = "eDP-1";
    };
  };

  home.stateVersion = "24.05";
}
