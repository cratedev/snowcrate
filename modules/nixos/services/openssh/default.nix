{
  config,
  lib,
  inputs,
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
    authorizedKeys = mkOpt (listOf str) [] "The public keys to apply.";
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
        {
          path = "/persist/etc/ssh/ssh_host_rsa_key";
          type = "rsa";
          bits = 4096;
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

    crate.user.extraOptions.openssh.authorizedKeys.keys = cfg.authorizedKeys;

    # Allow ssh-rsa for compatibility
    programs.ssh = {
      extraConfig = ''
        Host *
        	HostKeyAlgorithms +ssh-rsa
      '';
      knownHosts = import "${inputs.nix-ssh}/ssh/knownHosts";
    };
  };
}
