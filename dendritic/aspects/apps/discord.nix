{...}: {
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
