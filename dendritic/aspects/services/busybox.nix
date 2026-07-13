{...}: {
  flake.modules.nixos.busybox = {pkgs, ...}: {
    environment.systemPackages = [pkgs.busybox];
  };
}
