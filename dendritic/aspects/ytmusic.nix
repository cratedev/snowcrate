{...}: {
  flake.modules.homeManager.ytmusic = {pkgs, ...}: {
    home.packages = [pkgs.ytmdesktop];
  };
}
