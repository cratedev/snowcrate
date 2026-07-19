{self, ...}: {
  flake.modules.nixos.role-desktop = {
    imports = with self.modules.nixos; [role-base role-graphical steam];
  };

  flake.modules.homeManager.role-desktop = {
    imports = with self.modules.homeManager; [role-base role-graphical git-sync-check];
  };
}
