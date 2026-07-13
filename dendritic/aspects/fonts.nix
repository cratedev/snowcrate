{...}: {
  flake.modules.nixos.fonts = {pkgs, ...}: {
    environment.variables.LOG_ICONS = "true";
    environment.systemPackages = [pkgs.font-manager];

    fonts = {
      enableDefaultPackages = false;
      packages = with pkgs; [
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
        noto-fonts-color-emoji
        nerd-fonts.hack
        font-awesome
        material-design-icons
        material-symbols
        ibm-plex
        fira-code
        fira-code-symbols
        mplus-outline-fonts.githubRelease
        dina-font
        proggyfonts
        liberation_ttf
        jetbrains-mono
        nerd-fonts.jetbrains-mono
      ];
      fontconfig.defaultFonts = {
        serif = ["Noto Serif" "Noto Color Emoji"];
        sansSerif = ["Noto Sans" "Noto Color Emoji"];
        monospace = ["JetBrainsMono Nerd Font" "Noto Color Emoji"];
        emoji = ["Noto Color Emoji"];
      };
    };
  };
}
