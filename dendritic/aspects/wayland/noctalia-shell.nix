{inputs, ...}: {
  flake.modules.nixos.noctalia-shell = {...}: {
    environment.persistence."/persist".users.matt.directories = [
      ".config/noctalia"
      ".local/state/noctalia"
    ];
  };

  flake.modules.homeManager.noctalia-shell = {...}: {
    imports = [inputs.noctalia-shell.homeModules.default];

    programs.noctalia = {
      enable = true;
      # Installed and configured, but not autostarted -- DMS is the
      # active shell for now. Flip to true to make Noctalia active again.
      systemd.enable = false;
    };
  };
}
