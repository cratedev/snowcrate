{...}: {
  flake.modules.nixos.gvfs = {...}: {
    services.gvfs.enable = true;
  };
}
