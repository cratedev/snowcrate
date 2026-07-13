{...}: {
  flake.modules.nixos.libvirtd = {...}: {
    virtualisation.libvirtd.enable = true;
    users.users.matt.extraGroups = ["libvirtd"];
  };
}
