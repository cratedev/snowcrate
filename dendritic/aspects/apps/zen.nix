{inputs, ...}: {
  flake.modules.homeManager.zen = {...}: {
    imports = [inputs.zen-browser.homeModules.default];

    programs.zen-browser = {
      enable = true;
      profiles.matt = {
        isDefault = true;
        path = "deuteqrr.Default Profile";
        settings = {};
      };
    };
  };
}
