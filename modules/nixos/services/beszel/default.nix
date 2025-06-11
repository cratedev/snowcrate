{
  lib,
  config,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.services.beszel;
in {
  options.${namespace}.services.beszel = with types; {
    enable = mkBoolOpt false "Enable beszel;";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [beszel];
    systemd.services.beszel-agent = {
      description = "Beszel Agent";
      wantedBy = ["multi-user.target"];
      after = ["network.target"];
      serviceConfig = {
        ExecStart = "${pkgs.beszel}/bin/beszel-agent --key='ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINojBy0FFGbrpw85MQMPGFx3s1p+hSmkMP0QSXVfDPxB'";

        Restart = "always";
      };
    };
  };
}
