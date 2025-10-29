{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.services.openssh;
in {
  options.${namespace}.services.openssh = with types; {
    enable = mkBoolOpt false "Whether or not to configure OpenSSH support.";
    port = mkOpt port 2222 "The port to listen on (in addition to 22).";
    authorizedKeys = mkOpt (listOf str) lib.${namespace}.ssh.authorizedKeys "The public keys to apply.";
  };

  config = mkIf cfg.enable {
    services.openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
      hostKeys = [
        {
          path = "/persist/etc/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
      ];
      extraConfig = ''
        StreamLocalBindUnlink yes
      '';
      ports = [
        22
        cfg.port
      ];
    };

    users.users.${config.${namespace}.user.name}.openssh.authorizedKeys.keys = cfg.authorizedKeys;

    programs.ssh = {
      extraConfig = ''
        Host *
          HostKeyAlgorithms +ssh-rsa
      '';
      inherit (lib.${namespace}.ssh) knownHosts;
    };
  };
}
