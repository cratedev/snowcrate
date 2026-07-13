{...}: {
  flake.modules.nixos.fwupd = {pkgs, ...}: {
    environment.systemPackages = [pkgs.fwupd];
    services.fwupd.enable = true;
  };
}
