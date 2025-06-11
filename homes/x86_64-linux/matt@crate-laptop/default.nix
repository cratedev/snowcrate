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
    };
  };

  home.stateVersion = "24.05";
}
