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
      systemd.enable = true;
    };
  };
}
