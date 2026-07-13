{inputs, ...}: {
  flake.modules.nixos.niri = {pkgs, ...}: {
    imports = [inputs.niri.nixosModules.niri];

    nixpkgs.overlays = [inputs.niri.overlays.niri];

    niri-flake.cache.enable = false;
    systemd.user.services.niri-flake-polkit.enable = false;

    programs.niri = {
      enable = true;
      package = inputs.niri.packages.${pkgs.system}.niri-unstable;
    };

    programs.uwsm = {
      enable = true;
      waylandCompositors.niri = {
        prettyName = "niri";
        comment = "Niri compositor managed by UWSM";
        binPath = "/run/current-system/sw/bin/niri-session";
      };
    };
  };

  flake.modules.homeManager.niri = {
    config,
    lib,
    pkgs,
    ...
  }: {
    home.packages = [
      pkgs.xwayland-satellite
      pkgs.gtk4
      pkgs.awww
      pkgs.slurp
      pkgs.grim
      (import ../../../packages/dropdown-terminal-toggle {inherit pkgs;})
    ];

    programs.niri.settings = {
      environment = {};

      hotkey-overlay.skip-at-startup = true;

      spawn-at-startup = [
        {command = ["systemctl" "--user" "import-environment"];}
        {command = ["zen-beta"];}
        {command = ["uwsm" "app" "--" "1password" "--silent"];}
        {command = ["uwsm" "app" "--" "wl-paste" "--watch" "cliphist" "store"];}
      ];

      prefer-no-csd = true;

      input = {
        keyboard.xkb.layout = "us";
        touchpad = {
          tap = true;
          natural-scroll = true;
        };
        focus-follows-mouse.enable = true;
      };

      layout = {
        shadow = {
          enable = true;
          draw-behind-window = true;
        };
        gaps = 15;
        center-focused-column = "on-overflow";
        focus-ring = {
          enable = false;
          width = 1;
          active.color = "#fff";
        };
        border = {
          enable = true;
          width = 1;
          active.color = "#344e66";
          inactive.color = "#333333";
        };
        default-column-width = {proportion = 0.5;};
      };

      screenshot-path = null;

      animations = {
        slowdown = 1.5;
        window-open.kind.easing = {
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

      layer-rules = [
        {
          matches = [{namespace = "dms:blurwallpaper";}];
          place-within-backdrop = true;
        }
      ];

      window-rules = [
        {
          matches = [{title = "PolicyKit1";}];
          open-floating = true;
        }
        {
          matches = [{app-id = "1Password";}];
          open-maximized = false;
        }
        {
          matches = [{title = "dropdown-terminal";}];
          open-floating = true;
          default-column-width = {proportion = 1.0;};
          default-window-height = {proportion = 0.50;};
          default-floating-position = {
            x = 0;
            y = 0;
            relative-to = "bottom-left";
          };
        }
      ];

      binds = with config.lib.niri.actions; let
        sh = spawn "sh" "-c";
      in {
        "Mod+Shift+Slash".action = show-hotkey-overlay;

        "Mod+Return".action = spawn "ghostty" "-e" "zellij" "attach" "--create" "main";
        "Mod+grave".action = spawn "dropdown-terminal-toggle";
        "Mod+D".action = spawn "dms" "ipc" "call" "spotlight" "toggle";
        "Mod+S".action = spawn "dms" "ipc" "call" "settings" "toggle";
        "Mod+L".action = spawn "dms" "ipc" "call" "lock" "lock";
        "Mod+P".action = spawn "dms" "ipc" "call" "powermenu" "toggle";
        "Mod+C".action = spawn "dms" "ipc" "call" "control-center" "toggle";
        "Mod+Q".action = close-window;

        "Mod+WheelScrollDown".action = focus-column-right;
        "Mod+WheelScrollUp".action = focus-column-left;
        "Mod+Alt+WheelScrollDown".action = focus-workspace-down;
        "Mod+Alt+WheelScrollUp".action = focus-workspace-up;

        "Mod+Left".action = focus-column-left;
        "Mod+Down".action = focus-window-down;
        "Mod+Up".action = focus-window-up;
        "Mod+Right".action = focus-column-right;

        "Mod+Shift+Left".action = move-column-left;
        "Mod+Shift+Down".action = move-window-down;
        "Mod+Shift+Up".action = move-window-up;
        "Mod+Shift+Right".action = move-column-right;
        "Mod+Alt+Left".action = focus-workspace-down;
        "Mod+Alt+Right".action = focus-workspace-up;

        "Mod+Home".action = focus-column-first;
        "Mod+End".action = focus-column-last;
        "Mod+Shift+Home".action = move-column-to-first;
        "Mod+Shift+End".action = move-column-to-last;

        "Mod+Page_Down".action = focus-workspace-down;
        "Mod+Page_Up".action = focus-workspace-up;
        "Mod+Shift+2".action = move-column-to-workspace-down;
        "Mod+Shift+1".action = move-column-to-workspace-up;

        "Mod+1".action = focus-workspace 1;
        "Mod+2".action = focus-workspace 2;
        "Mod+3".action = focus-workspace 3;
        "Mod+4".action = focus-workspace 4;
        "Mod+5".action = focus-workspace 5;
        "Mod+6".action = focus-workspace 6;
        "Mod+7".action = focus-workspace 7;
        "Mod+8".action = focus-workspace 8;
        "Mod+9".action = focus-workspace 9;

        "Mod+Comma".action = consume-window-into-column;
        "Mod+Period".action = expel-window-from-column;

        "Mod+BracketLeft".action = consume-or-expel-window-left;
        "Mod+BracketRight".action = consume-or-expel-window-right;

        "Mod+R".action = switch-preset-column-width;
        "Mod+Shift+R".action = switch-preset-window-height;
        "Mod+Ctrl+R".action = reset-window-height;
        "Mod+F".action = maximize-column;
        "Mod+Shift+F".action = fullscreen-window;

        "Mod+Minus".action = set-column-width "-10%";
        "Mod+Equal".action = set-column-width "+10%";

        "Mod+I".action = sh ''grim -g "$(slurp)" ${config.home.homeDirectory}/images/screenshots/$(date +%y.%m.%d-%H:%M:%S).png'';
        "Mod+Shift+E".action = quit;

        "XF86AudioMicMute".action = spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle";
        "XF86AudioRaiseVolume".action = spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1+";
        "XF86AudioLowerVolume".action = spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1-";
        "XF86MonBrightnessUp".action = spawn (lib.getExe pkgs.brightnessctl) "s" "+5%";
        "XF86MonBrightnessDown".action = spawn (lib.getExe pkgs.brightnessctl) "s" "5%-";
      };
    };
  };
}
