{...}: {
  flake.modules.nixos.steam = {...}: {
    programs.steam.enable = true;
  };
}
