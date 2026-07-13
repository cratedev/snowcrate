{...}: {
  flake.modules.nixos.steam = {...}: {
    programs.steam.enable = true;
    users.users.matt.extraGroups = ["steamcmd"];
  };
}
