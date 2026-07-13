{...}: {
  flake.modules.homeManager.nautilus = {pkgs, ...}: {
    home.packages = [pkgs.nautilus];
  };
}
