{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; {
  options.${namespace}.profiles.base = {
    enable = mkBoolOpt false "Enable base profile";
  };

  config = mkIf config.${namespace}.profiles.base.enable {
    ${namespace} = {
      desktop = {
        niri.enable = true;
        addons = {
          dank.enable = true;
          gtk.enable = true;
        };
      };
      user.enable = true;
      xdg.enable = true;

      apps = {
        firefox.enable = true;
        ghostty.enable = true;
        zen.enable = true;
        obsidian.enable = true;
        discord.enable = true;
        nautilus.enable = true;
        orca.enable = true;
      };

      media = {
        ytmusic.enable = true;
        hypnotix.enable = true;
      };

      cli = {
        nushell.enable = true;
        fish.enable = true;
        btop.enable = true;
        zellij.enable = true;
        fzf.enable = true;
        just.enable = true;
        env.enable = true;
        managarr.enable = true;
        nix-index.enable = true;
      };

      theming.stylix.enable = true;

      tools = {
        nvf.enable = true;
        git.enable = true;
        wlsunset.enable = true;
      };
    };
  };
}
