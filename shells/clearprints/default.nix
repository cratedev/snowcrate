{
  pkgs,
  lib,
  ...
}:
pkgs.mkShell {
  name = "clearprints-dev";

  buildInputs = with pkgs; [
    python3
    python3Packages.pygobject3
    gobject-introspection
    libfprint
    gusb
    libfprint-2-tod1-goodix
  ];

  shellHook = ''
    echo "🔐 Fingerprint management shell"
    echo "Run: python fprint_clear_storage.py"
  '';
}
