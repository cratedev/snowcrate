{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.suites.desktop;
in {
  options.${namespace}.suites.desktop = with types; {
    enable = mkBoolOpt false "Enable Desktop module";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [];

    ${namespace} = {
      tools = {
        impermanence = enabled;
      };

      apps = {
        steam = enabled;
      };
    };
    age = {
      secrets = {
        id_ed25519 = {
          file = "${inputs.mysecrets}/secrets/desktop/id_ed25519.age";
          path = "/home/matt/.ssh/id_ed25519";
          owner = "matt";
          group = "users";
          mode = "600";
        };
        id_ed25519_pub = {
          file = "${inputs.mysecrets}/secrets/desktop/id_ed25519_pub.age";
          path = "/home/matt/.ssh/id_ed25519.pub";
          owner = "matt";
          group = "users";
          mode = "644";
        };
      };
      identityPaths = ["/etc/ssh/ssh_host_ed25519_key"];
    };

    users.users.matt = {
      isNormalUser = true;
      home = "/home/matt";
      extraGroups = ["users"];
    };
  };
}
