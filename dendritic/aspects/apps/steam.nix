{...}: {
  flake.modules.nixos.steam = {...}: {
    programs.steam.enable = true;
    users.users.matt.extraGroups = ["steamcmd"];

    environment.persistence."/persist".users.matt.directories = [
      ".steam"
      "games"
    ];
  };
}
