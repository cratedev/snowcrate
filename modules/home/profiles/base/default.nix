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
        addons.gtk.enable = false;
      };
      user.enable = true;
      xdg.enable = true;

      apps = {
        firefox.enable = false;
        ghostty.enable = true;
        zen.enable = true;
        obsidian.enable = true;
        discord.enable = true;
        nautilus.enable = true;
        orca.enable = false;
      };

      media = {
        ytmusic.enable = true;
        mpv.enable = true;
      };

      cli = {
        nushell.enable = false;
        fish.enable = true;
        starship.enable = true;
        zoxide.enable = true;
        btop.enable = true;
        zellij.enable = true;
        fzf.enable = true;
        just.enable = true;
        env.enable = true;
        nix-index.enable = true;
      };
      tools = {
        nvf.enable = true;
        git.enable = true;
      };
    };
  };
}
