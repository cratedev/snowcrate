{inputs, ...}: {
  # Was auto-discovered by snowfall-lib from shells/clearprints/; that
  # convention is gone now, so it's wired up explicitly as a perSystem
  # devShell instead. The helper script lives alongside this file in
  # ./clearprints/ (safe there since import-tree only globs *.nix files).
  systems = ["x86_64-linux"];

  perSystem = {system, ...}: let
    pkgs = inputs.nixpkgs.legacyPackages.${system};
  in {
    devShells.clearprints = pkgs.mkShell {
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
        echo "Fingerprint management shell"
        echo "Run: python dendritic/aspects/clearprints/fprint_clear_storage.py"
      '';
    };
  };
}
