{self, ...}: {
  flake.modules.nixos.suite-desktop = {
    imports = with self.modules.nixos; [suite-base steam];
  };
}
