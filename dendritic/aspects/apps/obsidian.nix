{...}: {
  flake.modules.nixos.obsidian = {...}: {
    environment.persistence."/persist".users.matt.directories = [".config/obsidian"];
  };

  flake.modules.homeManager.obsidian = {pkgs, ...}: {
    home.packages = [pkgs.obsidian];
  };
}
