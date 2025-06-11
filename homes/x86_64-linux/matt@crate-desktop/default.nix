{lib, ...}: {
  crate = {
    user = {
      name = "matt";
      fullName = "Matthew Henderson";
      email = "matt@crate.dev";
      hostname = "crate-desktop";
    };
    archetypes.desktop = {
      enable = true;
    };
  };

  home.stateVersion = "24.05";
}
