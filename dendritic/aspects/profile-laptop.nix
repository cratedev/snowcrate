{self, ...}: {
  flake.modules.homeManager.profile-laptop = {
    imports = [self.modules.homeManager.profile-base];
  };
}
