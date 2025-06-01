{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.hardware.networking;
in {
  options.${namespace}.hardware.networking = with types; {
    enable = mkBoolOpt false "Whether or not to enable networking support";
    hosts = mkOpt attrs {} (mdDoc "An attribute set to merge with `networking.hosts`");
  };

  config = mkIf cfg.enable {
    crate.user.extraGroups = ["networkmanager"];

    networking = {
      networkmanager = {
        enable = true;
        dhcp = "internal";
      };
    };

    systemd.services.NetworkManager-wait-online.enable = false;
  };
}
