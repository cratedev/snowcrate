{...}: {
  flake.modules.nixos.wlclipboard = {pkgs, ...}: {
    environment.systemPackages = [pkgs.wl-clipboard];
  };
}
