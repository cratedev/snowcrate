{...}: {
  flake.modules.homeManager.carapace = {...}: {
    programs.carapace.enable = true;
  };
}
