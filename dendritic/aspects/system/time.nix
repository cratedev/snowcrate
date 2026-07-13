{...}: {
  flake.modules.nixos.time = {...}: {
    time.timeZone = "America/Toronto";
  };
}
