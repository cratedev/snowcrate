{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.desktop.addons.hyprlock;
in {
  options.${namespace}.desktop.addons.hyprlock = with types; {
    enable = mkBoolOpt false "Whether or not to turn on hyprlock config.";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [gtk4 swww slurp];

    programs.hyprlock = {
      enable = true;
      settings = {
        general = {
          grace = "0";
          hide_cursor = "true";
          no_fade_out = "false";
        };

        auth = {
          fingerprint = {
            enabled = "true";
          };
        };

        animations = {
          enabled = "true";
          bezier = "linear, 1, 1, 0, 0";
          animation = [
            "fade, 1, 10, linear"
          ];
        };

        background = [
          {
            monitor = "";
            path = "${config.home.homeDirectory}/snowcrate/assets/hypr/hyprlock.png";
            blur_passes = "0";
            contrast = "0.8916";
            brightness = "0.8916";
            vibrancy = "0.8916";
            vibrancy_darkness = "0.0";
          }
        ];
        input-field = [
          {
            monitor = "";
            size = "320, 55";
            outline_thickness = "0";
            dots_size = "0.2";
            dots_spacing = "0.2";
            dots_center = "true";
            outer_color = "rgba(255, 255, 255, 0)";
            inner_color = "rgba(255, 255, 255, 0.1)";
            font_color = "rgb(200, 200, 200)";
            fade_on_empty = "false";
            font_family = "SF Pro Display Bold";
            placeholder_text = "<i><span foreground=\"##ffffff99\">  </span></i>";
            hide_input = "false";
            position = "0, -90";
            halign = "center";
            valign = "center";
          }
        ];
        label = [
          {
            monitor = "";
            text = "cmd[update:1000] echo \"<span>$(date +\"%I:%M\")</span>\"";
            color = "rgba(216, 222, 233, 0.80)";
            font_size = "60";
            font_family = "SF Pro Display Bold";
            position = "0, 60";
            halign = "center";
            valign = "center";
          }
          {
            monitor = "";
            text = "cmd[update:1000] echo -e \"$(date +\"%A, %B %d\")\"";
            color = "rgba(216, 222, 233, .80)";
            font_size = "19";
            font_family = "SF Pro Display Bold";
            position = "0, 0";
            halign = "center";
            valign = "center";
          }
          {
            monitor = "";
            text = " 󰐥  󰜉  󰤄 ";
            color = "rgba(255, 255, 255, 0.6)";
            font_size = "50";
            position = "0, 100";
            halign = "center";
            valign = "bottom";
          }
        ];
      };
    };
  };
}
