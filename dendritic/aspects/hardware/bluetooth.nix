{...}: {
  flake.modules.nixos.bluetooth = {...}: {
    hardware.bluetooth.enable = true;

    environment.persistence."/persist".directories = ["/var/lib/bluetooth"];
  };
}
