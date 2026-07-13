{...}: {
  flake.modules.nixos.networking = {...}: {
    users.users.matt.extraGroups = ["networkmanager"];

    networking.networkmanager = {
      enable = true;
      dhcp = "internal";
    };

    systemd.services.NetworkManager-wait-online.enable = false;
  };
}
