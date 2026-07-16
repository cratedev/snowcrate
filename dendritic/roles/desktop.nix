{self, ...}: {
  flake.modules.nixos.role-desktop = {
    imports = with self.modules.nixos; [role-base steam];
  };

  flake.modules.homeManager.role-desktop = {
    imports = with self.modules.homeManager; [role-base git-sync-check];
  };
}
