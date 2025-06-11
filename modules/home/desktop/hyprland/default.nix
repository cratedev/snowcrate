{
  config,
  lib,
  pkgs,
  inputs,
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
    home = {
      packages = with pkgs; [
        playerctl
        gtk4
        swww
        fzf
        foot
        chafa
        jq
        slurp
        hyprcursor
        inputs.grim-hyprland.packages.${system}.default
      ];
      file = {
        ".config/hypr/scripts" = {
          source = ./scripts;
          recursive = true;
        };
      };
    };

    stylix.targets.hyprland.enable = true; # Enable Stylix theming for Hyprland
    wayland.windowManager.hyprland = {
      enable = true;
      extraConfig = ''
        ${cfg.appendConfig}
             submap=alttab
             bind = ALT, tab, sendshortcut, , tab, class:alttab
             bind = ALT SHIFT, tab, sendshortcut, shift, tab, class:alttab
             submap = reset
             bindrt = ALT, ALT_L, exec, $XDG_CONFIG_HOME/hypr/scripts/alttab/disable.sh ; hyprctl -q dispatch sendshortcut , return,class:alttab
             bindrt = ALT SHIFT, ALT_L, exec, $XDG_CONFIG_HOME/hypr/scripts/alttab/disable.sh ; hyprctl -q dispatch sendshortcut , return,class:alttab
      '';
      settings = {
        "$mod" = "SUPER";

        monitor = [
          "eDP-1,preferred,auto,1"
        ];

        env = [
          "ELECTRON_OZONE_PLATFORM_HINT,wayland"
        ];

        ecosystem = {
          "no_update_news" = true;
          "no_donation_nag" = true;
        };

        exec-once = [
          "uwsm app -- hyprlock"
          "uwsm app -- qs -c caelestia"
          "1password --silent"
          "uwsm app -- foot --server"
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
          gaps_in = 15;
          gaps_out = 20;
          border_size = 1;
        };

        misc = {
          disable_splash_rendering = true;
          disable_hyprland_logo = true;
        };

        workspace = [
          "w[t1], gapsout:10, gapsin:10"
          "w[tg1], gapsout:10, gapsin:10"
          "f[1], gapsout:10, gapsin:10"
          "special:alttab, gapsout:0, gapsin:0, bordersize:0"
        ];

        windowrulev2 = [
          "bordersize 0, floating:0, onworkspace:w[t1]"
          "rounding 6, floating:0, onworkspace:w[t1]"
          "bordersize 0, floating:0, onworkspace:w[tg1]"
          "rounding 6, floating:0, onworkspace:w[tg1]"
          "bordersize 0, floating:0, onworkspace:f[1]"
          "rounding 6, floating:0, onworkspace:f[1]"
          "noanim, class:alttab"
          "stayfocused, class:alttab"
          "workspace special:alttab, class:alttab"
          "bordersize 0, class:alttab"
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

          blur = {
            enabled = true;
            size = 2;
            passes = 1;
          };

          shadow = {
            enabled = true;
            range = 8;
            render_power = 3;
          };
        };

        bind =
          [
            "$mod, RETURN, exec, uwsm app -- ghostty -e zellij attach --create main"
            #            "$mod, D, exec, uwsm app -- rofi -show drun -theme ~/.config/rofi/styles/style-16.rasi"
            "$mod, D, exec, qs -c caelestia ipc call drawers toggle launcher"

            "$mod, H, exec, qs -c caelestia ipc call drawers toggle dashboard"
            "$mod, P, exec, qs -c caelestia ipc call drawers toggle session"
            "$mod, E, exec, nemo"
            "$mod, I, exec, sh -c 'grim -g \"$(slurp)\" /home/matt/images/screenshots/$(date +%y.%m.%d-%H:%M:%S).png'"

            "$mod, L, exec, hyprlock"

            "$mod, Q, killactive"
            "$mod, V, togglefloating"
            "$mod, F, fullscreen, 1"
            "$mod, SPACE, exec, rofi -show run"
            #"$mod, P, pseudo"
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
            "ALT, TAB, exec, $HOME/.config/hypr/scripts/alttab/enable.sh 'down'"
            "ALT SHIFT, TAB, exec, $HOME/.config/hypr/scripts/alttab/enable.sh 'up'"
            "ALT, Return, exec, $XDG_CONFIG_HOME/hypr/scripts/alttab/disable.sh ; hyprctl -q dispatch sendshortcut , return, class:alttab"
            "ALT SHIFT, Return, exec, $XDG_CONFIG_HOME/hypr/scripts/alttab/disable.sh ; hyprctl -q dispatch sendshortcut , return, class:alttab"
            "ALT, escape, exec, $XDG_CONFIG_HOME/hypr/scripts/alttab/disable.sh ; hyprctl -q dispatch sendshortcut , escape,class:alttab"
            "ALT SHIFT, escape, exec, $XDG_CONFIG_HOME/hypr/scripts/alttab/disable.sh ; hyprctl -q dispatch sendshortcut , escape,class:alttab"
            ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+"
            ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-"
            ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
            ", XF86AudioPlay, exec, playerctl play-pause"
            ", XF86MonBrightnessUp, exec, brightnessctl set +5%"
            ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
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
