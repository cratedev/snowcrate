{...}: {
  flake.modules.nixos.cockpit = {...}: {
    services.cockpit = {
      enable = true;
      port = 9090;
      openFirewall = true;
    };
  };
}
