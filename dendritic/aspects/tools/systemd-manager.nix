{...}: {
  flake.modules.nixos.systemd-manager = {pkgs, ...}: {
    environment.systemPackages = [pkgs.systemd-manager-tui];
  };
}
