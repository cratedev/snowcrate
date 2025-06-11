{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.desktop.niri;
in {
  options.${namespace}.desktop.niri = with types; {
    enable = mkBoolOpt false "Whether or not to turn on niri config.";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [gtk4 swww grim slurp];
    programs.niri = {
      settings = {
        environment."NIXOS_OZONE_WL" = "1";
        hotkey-overlay.skip-at-startup = true;

        spawn-at-startup = [
          #{command = ["swww-daemon"];}
          #{command = ["swww" "img" "${config.home.homeDirectory}/snow${namespace}/assets/wallpaper/12.png"];}
          #{command = ["waybar"];}
          {command = ["1password" "--ozone-platform-hint=auto" "--silent"];}
          {command = ["uwsm" "finalize"];}
          {command = ["uwsm app -- hyprlock"];}
          {command = ["uwsm app -- qs -c caelestia"];}

          {
            command = [
              "sh"
              "-c"
              ''
                outputs=$(${pkgs.wlr-randr}/bin/wlr-randr | grep -E '^[A-Za-z0-9-]+' | awk '{print $1}')
                if echo "$outputs" | grep -q "eDP-1"; then
                	# Laptop setup: Use internal screen only
                	${pkgs.wlr-randr}/bin/wlr-randr --output eDP-1 --pos 0,0 --scale 1.0
                else
                	# Desktop setup: Arrange external monitors
                	${pkgs.wlr-randr}/bin/wlr-randr --output HDMI-A-1 --pos 0,0 --transform normal --scale 1.0
                	${pkgs.wlr-randr}/bin/wlr-randr --output DP-1 --pos 2560,-560 --transform 270 --scale 1.0
                	${pkgs.wlr-randr}/bin/wlr-randr --output DP-3 --pos 4000,0 --transform normal --scale 1.0
                fi
                  swaybg -o DP-1 -i /home/matt/snowcrate/assets/wallpaper/vert.jpg
              ''
            ];
          }
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
          slowdown = 2.0;
          window-open.easing = {
            duration-ms = 250;
            curve = "ease-out-expo";
          };
          shaders.window-resize = ''
            vec4 resize_color(vec3 coords_curr_geo, vec3 size_curr_geo) {
            vec3 coords_next_geo = niri_curr_geo_to_next_geo * coords_curr_geo;

            vec3 coords_stretch = niri_geo_to_tex_next * coords_curr_geo;
            vec3 coords_crop = niri_geo_to_tex_next * coords_next_geo;

            // We can crop if the current window size is smaller than the next window
            // size. One way to tell is by comparing to 1.0 the X and Y scaling
            // coefficients in the current-to-next transformation matrix.
            bool can_crop_by_x = niri_curr_geo_to_next_geo[0][0] <= 1.0;
            bool can_crop_by_y = niri_curr_geo_to_next_geo[1][1] <= 1.0;

            vec3 coords = coords_stretch;
            if (can_crop_by_x)
            		coords.x = coords_crop.x;
            if (can_crop_by_y)
            		coords.y = coords_crop.y;

            vec4 color = texture2D(niri_tex_next, coords.st);

            // However, when we crop, we also want to crop out anything outside the
            // current geometry. This is because the area of the shader is unspecified
            // and usually bigger than the current geometry, so if we don't fill pixels
            // outside with transparency, the texture will leak out.
            //
            // When stretching, this is not an issue because the area outside will
            // correspond to client-side decoration shadows, which are already supposed
            // to be outside.
            if (can_crop_by_x && (coords_curr_geo.x < 0.0 || 1.0 < coords_curr_geo.x))
            		color = vec4(0.0);
            if (can_crop_by_y && (coords_curr_geo.y < 0.0 || 1.0 < coords_curr_geo.y))
            		color = vec4(0.0);

            return color;
            }
          '';
        };
        window-rules = [
          {
            matches = [{title = "PolicyKit1";}]; # Match all windows (or adjust the regex to match specific apps)
            open-floating = true;
          }
          {
            matches = [{app-id = "1Password";}];
            open-maximized = false;
          }
        ];
        binds = with config.lib.niri.actions; let
          sh = spawn "sh" "-c";
        in {
          "Mod+Shift+Slash".action = show-hotkey-overlay;

          "Mod+Return".action = spawn "ghostty" "-e" "zellij" "attach" "--create" "main";
          "Mod+D".action = spawn "rofi" "-show" "drun" "-run-command" "uwsm app -- {cmd}" "-theme" ".config/rofi/styles/style-16.rasi";
          "Mod+Q".action = close-window;

          "Mod+Left".action = focus-column-left;
          "Mod+Down".action = focus-window-down;
          "Mod+Up".action = focus-window-up;
          "Mod+Right".action = focus-column-right;

          "Mod+Shift+Left".action = move-column-left;
          "Mod+Shift+Down".action = move-window-down;
          "Mod+Shift+Up".action = move-window-up;
          "Mod+Shift+Right".action = move-column-right;

          "Mod+Home".action = focus-column-first;
          "Mod+End".action = focus-column-last;
          "Mod+Shift+Home".action = move-column-to-first;
          "Mod+Shift+End".action = move-column-to-last;

          "Mod+Page_Down".action = focus-workspace-down;
          "Mod+Page_Up".action = focus-workspace-up;
          "Mod+Shift+Page_Down".action = move-column-to-workspace-down;
          "Mod+Shift+Page_Up".action = move-column-to-workspace-up;

          "Mod+1".action = focus-workspace 1;
          "Mod+2".action = focus-workspace 2;
          "Mod+3".action = focus-workspace 3;
          "Mod+4".action = focus-workspace 4;
          "Mod+5".action = focus-workspace 5;
          "Mod+6".action = focus-workspace 6;
          "Mod+7".action = focus-workspace 7;
          "Mod+8".action = focus-workspace 8;
          "Mod+9".action = focus-workspace 9;

          "Mod+Shift+1".action = move-column-to-workspace 1;
          "Mod+Shift+2".action = move-column-to-workspace 2;
          "Mod+Shift+3".action = move-column-to-workspace 3;
          "Mod+Shift+4".action = move-column-to-workspace 4;
          "Mod+Shift+5".action = move-column-to-workspace 5;
          "Mod+Shift+6".action = move-column-to-workspace 6;
          "Mod+Shift+7".action = move-column-to-workspace 7;
          "Mod+Shift+8".action = move-column-to-workspace 8;
          "Mod+Shift+9".action = move-column-to-workspace 9;

          "Mod+Comma".action = consume-window-into-column;
          "Mod+Period".action = expel-window-from-column;

          "Mod+BracketLeft".action = consume-or-expel-window-left;
          "Mod+BracketRight".action = consume-or-expel-window-right;

          "Mod+R".action = switch-preset-column-width;
          "Mod+Shift+R".action = switch-preset-window-height;
          "Mod+Ctrl+R".action = reset-window-height;
          "Mod+F".action = maximize-column;
          "Mod+Shift+F".action = fullscreen-window;
          "Mod+C".action = center-column;

          "Mod+Minus".action = set-column-width "-10%";
          "Mod+Equal".action = set-column-width "+10%";

          "Print".action = screenshot;
          "Mod+I".action = sh ''grim -g "$(slurp)" /home/matt/images/screenshots/$(date +%y.%m.%d-%H:%M:%S).png'';
          "Mod+L".action = spawn "hyprlock";
          "Mod+Shift+E".action = quit;

          "XF86AudioMicMute".action = spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle";
          "XF86AudioRaiseVolume".action = spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1+";
          "XF86AudioLowerVolume".action = spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1-";
          "XF86MonBrightnessUp".action = spawn (lib.getExe pkgs.brightnessctl) "s" "+5%";
          "XF86MonBrightnessDown".action = spawn (lib.getExe pkgs.brightnessctl) "s" "5%-";
        };
      };
    };
  };
}
