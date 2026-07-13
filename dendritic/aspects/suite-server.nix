{self, ...}: {
  # Identical to suite-base today (matches the original
  # modules/nixos/suites/server, which only ever cascaded to base and never
  # added anything server-specific).
  flake.modules.nixos.suite-server = {
    imports = [self.modules.nixos.suite-base];
  };
}
