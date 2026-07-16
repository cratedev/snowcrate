{inputs, ...}: {
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
        echo "Run: python dendritic/shells/clearprints/fprint_clear_storage.py"
      '';
    };
  };
}
