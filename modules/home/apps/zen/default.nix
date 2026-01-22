{
  config,
  lib,
  inputs,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.apps.zen;
in {
  options.${namespace}.apps.zen = with types; {
    enable = mkBoolOpt false "Enable zen";
    enableDankMaterialShell = mkBoolOpt false "Enable DankMaterialShell theming";
  };

  config = mkIf cfg.enable {
    home.packages = [
      inputs.zen-browser.packages.x86_64-linux.default
    ];

    # DankMaterialShell theming
    home.activation.zenDankMaterialShell = mkIf cfg.enableDankMaterialShell (
      config.lib.dag.entryAfter ["writeBoundary"] ''
        # Find the default Zen profile directory
        PROFILE_DIR=$(find ${config.home.homeDirectory}/.zen -maxdepth 1 -type d -name "*.default-release" -o -name "*.Default Profile" 2>/dev/null | head -n 1)

        if [ -n "$PROFILE_DIR" ] && [ -d "$PROFILE_DIR" ]; then
          $DRY_RUN_CMD mkdir -p "$PROFILE_DIR/chrome"

          # Create symlink to DankMaterialShell theme
          if [ -f "${config.home.homeDirectory}/.config/DankMaterialShell/zen.css" ]; then
            $DRY_RUN_CMD ln -sf "${config.home.homeDirectory}/.config/DankMaterialShell/zen.css" "$PROFILE_DIR/chrome/userChrome.css"
            echo "DankMaterialShell theme linked to Zen browser profile"
          else
            echo "Warning: DankMaterialShell zen.css not found at ${config.home.homeDirectory}/.config/DankMaterialShell/zen.css"
          fi
        else
          echo "Warning: Zen browser profile directory not found. Launch Zen browser first to create a profile."
        fi
      ''
    );
  };
}
