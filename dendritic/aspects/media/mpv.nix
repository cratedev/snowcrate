{...}: {
  flake.modules.homeManager.mpv = {pkgs, ...}: {
    programs.mpv = {
      enable = true;
      package = pkgs.mpv.override {
        scripts = [pkgs.mpvScripts.modernz pkgs.mpvScripts.sponsorblock];
      };
      config = {
        profile = "high-quality";
        ytdl-format = "bestvideo+bestaudio";
        osc = "no";
      };
    };
  };
}
