{
  inputs.nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0"; # Stable Nixpkgs
  outputs = {self, ...} @ inputs: let
    supportedSystems = [
      "x86_64-linux"
    ];

    forEachSupportedSystem = f:
      inputs.nixpkgs.lib.genAttrs supportedSystems (
        system:
          f {
            pkgs = import inputs.nixpkgs {
              inherit system;
              config.allowUnfree = true;
            };
          }
      );
  in {
    devShells = forEachSupportedSystem (
      {pkgs}: {
        default = pkgs.mkShell {
          buildInputs = with pkgs; [
            python3
            python3Packages.pygobject3
            gobject-introspection
            libfprint
            gusb
            libfprint-2-tod1-goodix
          ];
          shellHook = ''
            echo "Run 'sudo LD_LIBRARY_PATH=$LD_LIBRARY_PATH PYTHONPATH=$PYTHONPATH GI_TYPELIB_PATH=$GI_TYPELIB_PATH python3 ./fprint_clear_storage.py'"
          '';
        };
      }
    );
  };
}
