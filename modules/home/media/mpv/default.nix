{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.media.mpv;
in {
  options.${namespace}.media.mpv = with types; {
    enable = mkBoolOpt false "Enable mpv";
  };
  config = mkIf cfg.enable {
    programs.mpv = {
      enable = true;
      package = pkgs.mpv.override {
        scripts = with pkgs.mpvScripts; [
          #uosc
          modernz
          sponsorblock
        ];
      };
      config = {
        profile = "high-quality";
        ytdl-format = "bestvideo+bestaudio";
        osc = "no";
      };
    };
  };
}
