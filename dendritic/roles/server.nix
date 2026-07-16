{self, ...}: {
  flake.modules.nixos.role-server = {
    imports = [self.modules.nixos.role-base];
  };

  flake.modules.homeManager.role-server = {
    imports = [self.modules.homeManager.role-base];
  };
}
