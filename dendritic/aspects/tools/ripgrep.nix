{...}: {
  flake.modules.nixos.ripgrep = {pkgs, ...}: {
    environment.systemPackages = [pkgs.ripgrep];
  };
}
