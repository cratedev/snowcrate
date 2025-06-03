{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.desktop.hyprland;
in {
  options.${namespace}.desktop.hyprland = with types; {
    enable = mkBoolOpt false "Whether or not to turn on hyprland config.";
    startup = mkOpt (listOf str) [] "List of commands to run when you login";
    appendConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = ''
        Extra configuration lines to add to bottom of `~/.config/hyprland/hyprland.conf`.
      '';
    };
    prependConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = ''
        Extra configuration lines to add to top of `~/.config/hyprland/hyprland.conf`.
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [gtk3 swww grim slurp];
    home.sessionVariables.NIXOS_OZONE_WL = "1";
    programs.kitty.enable = true; # required for the default Hyprland config

    wayland.windowManager.hyprland = {
      enable = true;
      settings = {
        "$mod" = "SUPER";

        monitor = [
          "eDP-1,preferred,auto,1"
        ];

        env = [
        ];

        exec-once = [
          "swww-daemon"
          "swww img /home/matt/snowcrate/assets/wallpaper/12.png"
          "waybar"
          #          "1password --ozone-platform-hint=auto"
          #          "nm-applet"
          #          "blueman-applet"
          #          "dunst"
          #          "udiskie"
          #          "wl-paste --watch cliphist store"
        ];

        input = {
          kb_layout = "us";
          follow_mouse = 1;
          touchpad = {
            natural_scroll = true;
            tap-to-click = true;
          };
        };

        general = {
          gaps_in = 10;
          gaps_out = 10;
          border_size = 1;
        };

        workspace = [
          "w[t1], gapsout:10, gapsin:10"
          "w[tg1], gapsout:10, gapsin:10"
          "f[1], gapsout:10, gapsin:10"
        ];

        windowrulev2 = [
          "bordersize 0, floating:0, onworkspace:w[t1]"
          "rounding 0, floating:0, onworkspace:w[t1]"
          "bordersize 0, floating:0, onworkspace:w[tg1]"
          "rounding 0, floating:0, onworkspace:w[tg1]"
          "bordersize 0, floating:0, onworkspace:f[1]"
          "rounding 0, floating:0, onworkspace:f[1]"
        ];

        animations = {
          enabled = "yes";

          # Some default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more
          bezier = [
            "easein, 0.47, 0, 0.745, 0.715"
            "myBezier, 0.05, 0.9, 0.1, 1.05"
            "overshot, 0.13, 0.99, 0.29, 1.02"
            "scurve, 0.98, 0.01, 0.02, 0.98"
          ];

          animation = [
            "border, 1, 10, default"
            "fade, 1, 10, default"
            "windows, 1, 5, overshot, popin 10%"
            "windowsOut, 1, 7, default, popin 10%"
            "workspaces, 1, 6, overshot, slide"
          ];
        };

        decoration = {
          rounding = 6;
        };

        bind =
          [
            "$mod, RETURN, exec, ghostty -e zellij attach --create main"
            "$mod, D, exec, rofi -show drun -theme ~/.config/rofi/styles/style-16.rasi"
            "$mod, E, exec, nemo"
            "$mod, Q, killactive"
            "$mod, V, togglefloating"
            "$mod, F, fullscreen"
            "$mod, S, exec, ~/.config/hyprland/scripts/fake_fullscreen.sh"
            "$mod, SPACE, exec, rofi -show run"
            "$mod, P, pseudo"
            "$mod, left, movefocus, l"
            "$mod, up, movefocus, u"
            "$mod, right, movefocus, r"
            "$mod, down, movefocus, d"
            "$mod SHIFT, left, swapwindow, l"
            "$mod SHIFT, up, swapwindow, u"
            "$mod SHIFT, right, swapwindow, r"
            "$mod SHIFT, down, swapwindow, d"
            "$mod, TAB, workspace, e+1"
            "$mod SHIFT, TAB, workspace, e-1"
            "$mod, S, togglesplit"
            "$mod SHIFT, E, exit"
            "$mod ALT, R, exec, hyprctl reload"
          ]
          ++ (
            # workspaces
            # binds $mod + [shift +] {1..9} to [move to] workspace {1..9}
            builtins.concatLists (builtins.genList (
                i: let
                  ws = i + 1;
                in [
                  "$mod, code:1${toString i}, workspace, ${toString ws}"
                  "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
                ]
              )
              9)
          );
      };
    };
  };
}
