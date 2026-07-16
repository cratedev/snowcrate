{self, ...}: {
  flake.modules.nixos.role-laptop = {
    imports = with self.modules.nixos; [role-base fingerprint power];
  };

  flake.modules.homeManager.role-laptop = {
    imports = with self.modules.homeManager; [role-base git-sync-check];
  };
}
