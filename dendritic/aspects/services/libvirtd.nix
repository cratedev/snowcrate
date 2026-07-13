{...}: {
  flake.modules.nixos.libvirtd = {...}: {
    virtualisation.libvirtd.enable = true;
  };
}
