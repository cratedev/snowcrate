{self, ...}: {
  flake.modules.homeManager.profile-desktop = {
    imports = [self.modules.homeManager.profile-base];
  };
}
