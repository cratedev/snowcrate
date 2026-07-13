{...}: {
  flake.modules.homeManager.discord = {pkgs, ...}: {
    home.packages = [pkgs.vesktop];
  };
}
