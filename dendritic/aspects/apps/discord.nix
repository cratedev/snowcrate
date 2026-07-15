{...}: {
  flake.modules.nixos.discord = {...}: {
    environment.persistence."/persist".users.matt.directories = [".config/vesktop"];
  };

  flake.modules.homeManager.discord = {...}: {
    programs.vesktop = {
      enable = true;
      settings = {};
      vencord = {
        settings = {};
        themes = {};
      };
    };
  };
}
