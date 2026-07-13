{...}: {
  flake.modules.nixos.docker = {...}: {
    virtualisation.docker = {
      enable = true;
      enableOnBoot = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
    };
  };
}
