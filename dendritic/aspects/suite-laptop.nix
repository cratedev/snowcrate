{self, ...}: {
  flake.modules.nixos.suite-laptop = {
    imports = with self.modules.nixos; [suite-base fingerprint power];
  };
}
