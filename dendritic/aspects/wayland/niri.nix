{inputs, ...}: {
  flake.modules.nixos.niri = {pkgs, ...}: {
    imports = [inputs.niri-nix.nixosModules.default];

    nixpkgs.overlays = [inputs.niri-nix.overlays.niri-nix];

    programs.niri = {
      enable = true;
      package = pkgs.niri-unstable;
      withUWSM = true;
      # xdg-portal is configured separately in aspects/services/portals.nix.
      withXDG = false;
    };
  };

  flake.modules.homeManager.niri = {
    config,
    lib,
    pkgs,
    ...
  }: {
    imports = [inputs.niri-nix.homeModules.default];

    # Pre-seeds empty placeholders for the dms/*.kdl includes below,
    # since niri parses config.kdl before DMS generates them. Only
    # creates missing files, so real DMS-generated content is kept.
    home.activation.dmsNiriPlaceholders = lib.hm.dag.entryAfter ["writeBoundary"] ''
      run mkdir -p "$HOME/.config/niri/dms"
      for f in alttab binds colors cursor layout outputs windowrules wpblur; do
        target="$HOME/.config/niri/dms/$f.kdl"
        [ -e "$target" ] || run touch "$target"
      done
    '';

    home.packages = [
      pkgs.xwayland-satellite-unstable
      pkgs.gtk4
      pkgs.awww
      pkgs.slurp
      pkgs.grim
      (import ../../../packages/dropdown-terminal-toggle {inherit pkgs;})
    ];

    wayland.windowManager.niri = {
      enable = true;

      # Matches the NixOS module's package; niri-nix's config validation
      # requires cfg.package.system to be non-null.
      package = pkgs.niri-unstable;

      # DMS generates these under ~/.config/niri/dms/ at runtime.
      # extraConfig is appended after the settings-derived config, so
      # these parse last.
      extraConfig = ''
        include "dms/alttab.kdl"
        include "dms/binds.kdl"
        include "dms/colors.kdl"
        include "dms/cursor.kdl"
        include "dms/layout.kdl"
        include "dms/outputs.kdl"
        include "dms/windowrules.kdl"
        include "dms/wpblur.kdl"
      '';

      settings = {
        hotkey-overlay.skip-at-startup = [];

        spawn-at-startup = [
          ["systemctl" "--user" "import-environment"]
          ["uwsm" "app" "--" "zen-beta"]
          ["uwsm" "app" "--" "1password" "--silent"]
          ["uwsm" "app" "--" "wl-paste" "--watch" "cliphist" "store"]
        ];

        prefer-no-csd = [];

        input = {
          keyboard.xkb.layout = "us";
          touchpad = {
            tap = [];
            natural-scroll = [];
          };
          focus-follows-mouse = [];
        };

        layout = {
          shadow = {
            on = [];
            draw-behind-window = true;
          };
          gaps = 15;
          center-focused-column = "on-overflow";
          focus-ring = {
            off = [];
            width = 1;
            active-color = "#fff";
          };
          border = {
            width = 1;
            active-color = "#344e66";
            inactive-color = "#333333";
          };
          default-column-width.proportion = 0.5;
        };

        screenshot-path = null;

        animations = {
          slowdown = 1.5;
          window-open = {
            duration-ms = 250;
            curve = "ease-out-expo";
          };
          window-resize.custom-shader = ''
            vec4 resize_color(vec3 coords_curr_geo, vec3 size_curr_geo) {
            vec3 coords_next_geo = niri_curr_geo_to_next_geo * coords_curr_geo;

            vec3 coords_stretch = niri_geo_to_tex_next * coords_curr_geo;
            vec3 coords_crop = niri_geo_to_tex_next * coords_next_geo;

            bool can_crop_by_x = niri_curr_geo_to_next_geo[0][0] <= 1.0;
            bool can_crop_by_y = niri_curr_geo_to_next_geo[1][1] <= 1.0;

            vec3 coords = coords_stretch;
            if (can_crop_by_x)
            		coords.x = coords_crop.x;
            if (can_crop_by_y)
            		coords.y = coords_crop.y;

            vec4 color = texture2D(niri_tex_next, coords.st);

            if (can_crop_by_x && (coords_curr_geo.x < 0.0 || 1.0 < coords_curr_geo.x))
            		color = vec4(0.0);
            if (can_crop_by_y && (coords_curr_geo.y < 0.0 || 1.0 < coords_curr_geo.y))
            		color = vec4(0.0);

            return color;
            }
          '';
        };

        layer-rule = [
          {
            match._props.namespace = "dms:blurwallpaper";
            place-within-backdrop = true;
          }
        ];

        window-rule = [
          {
            match._props.app-id = "1Password";
            open-maximized = false;
          }
          {
            match._props.title = "dropdown-terminal";
            open-floating = true;
            default-column-width.proportion = 1.0;
            default-window-height.proportion = 0.50;
            default-floating-position._props = {
              x = 0;
              y = 0;
              relative-to = "bottom-left";
            };
          }
        ];

        binds = {
          "Mod+Shift+Slash".show-hotkey-overlay = [];

          "Mod+Return".spawn = ["ghostty" "-e" "zellij" "attach" "--create" "main"];
          "Mod+grave".spawn = "dropdown-terminal-toggle";
          "Mod+D".spawn = ["dms" "ipc" "call" "spotlight" "toggle"];
          "Mod+S".spawn = ["dms" "ipc" "call" "settings" "toggle"];
          "Mod+L".spawn = ["dms" "ipc" "call" "lock" "lock"];
          "Mod+P".spawn = ["dms" "ipc" "call" "powermenu" "toggle"];
          "Mod+C".spawn = ["dms" "ipc" "call" "control-center" "toggle"];
          "Mod+Q".close-window = [];

          "Mod+WheelScrollDown".focus-column-right = [];
          "Mod+WheelScrollUp".focus-column-left = [];
          "Mod+Alt+WheelScrollDown".focus-workspace-down = [];
          "Mod+Alt+WheelScrollUp".focus-workspace-up = [];

          "Mod+Left".focus-column-left = [];
          "Mod+Down".focus-window-down = [];
          "Mod+Up".focus-window-up = [];
          "Mod+Right".focus-column-right = [];

          "Mod+Shift+Left".move-column-left = [];
          "Mod+Shift+Down".move-window-down = [];
          "Mod+Shift+Up".move-window-up = [];
          "Mod+Shift+Right".move-column-right = [];
          "Mod+Alt+Left".focus-workspace-down = [];
          "Mod+Alt+Right".focus-workspace-up = [];

          "Mod+Home".focus-column-first = [];
          "Mod+End".focus-column-last = [];
          "Mod+Shift+Home".move-column-to-first = [];
          "Mod+Shift+End".move-column-to-last = [];

          "Mod+Page_Down".focus-workspace-down = [];
          "Mod+Page_Up".focus-workspace-up = [];
          "Mod+Shift+2".move-column-to-workspace-down = [];
          "Mod+Shift+1".move-column-to-workspace-up = [];

          "Mod+1".focus-workspace = 1;
          "Mod+2".focus-workspace = 2;
          "Mod+3".focus-workspace = 3;
          "Mod+4".focus-workspace = 4;
          "Mod+5".focus-workspace = 5;
          "Mod+6".focus-workspace = 6;
          "Mod+7".focus-workspace = 7;
          "Mod+8".focus-workspace = 8;
          "Mod+9".focus-workspace = 9;

          "Mod+Comma".consume-window-into-column = [];
          "Mod+Period".expel-window-from-column = [];

          "Mod+BracketLeft".consume-or-expel-window-left = [];
          "Mod+BracketRight".consume-or-expel-window-right = [];

          "Mod+R".switch-preset-column-width = [];
          "Mod+Shift+R".switch-preset-window-height = [];
          "Mod+Ctrl+R".reset-window-height = [];
          "Mod+F".maximize-column = [];
          "Mod+Shift+F".fullscreen-window = [];

          "Mod+Minus".set-column-width = "-10%";
          "Mod+Equal".set-column-width = "+10%";

          "Mod+I".spawn = ["sh" "-c" ''grim -g "$(slurp)" ${config.home.homeDirectory}/images/screenshots/$(date +%y.%m.%d-%H:%M:%S).png''];
          "Mod+Shift+E".quit = [];

          "XF86AudioMicMute".spawn = ["wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle"];
          "XF86AudioRaiseVolume".spawn = ["wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1+"];
          "XF86AudioLowerVolume".spawn = ["wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1-"];
          "XF86MonBrightnessUp".spawn = ["${lib.getExe pkgs.brightnessctl}" "s" "+5%"];
          "XF86MonBrightnessDown".spawn = ["${lib.getExe pkgs.brightnessctl}" "s" "5%-"];
        };
      };
    };
  };
}
