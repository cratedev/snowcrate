{
  lib,
  inputs,
  snowfall-inputs,
}: rec {
  override-meta = meta: package:
    package.overrideAttrs (attrs: {
      meta = (attrs.meta or {}) // meta;
    });

  ssh = import ./ssh {inherit lib;};
  module = import ./module {inherit lib;};
  file = import ./file {inherit lib;};
}
