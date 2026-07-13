{...}: {
  flake.modules.nixos.cliphist = {pkgs, ...}: {
    environment.systemPackages = [pkgs.cliphist];
  };
}
