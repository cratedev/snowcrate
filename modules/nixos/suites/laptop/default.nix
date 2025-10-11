{
  config,
  lib,
  inputs,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.suites.laptop;
in {
  options.${namespace}.suites.laptop = with types; {
    enable = mkBoolOpt false "Enable Laptop module";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [];

    ${namespace} = {
      tools = {
        impermanence = enabled;
        virt = enabled;
      };

      hardware = {
        fingerprint = enabled;
      };

      services = {
        power = enabled;
      };
    };
    age = {
      secrets = {
        id_ed25519 = {
          file = "${inputs.mysecrets}/secrets/laptop/id_ed25519.age";
          path = "/home/matt/.ssh/id_ed25519";
          owner = "matt";
          group = "users";
          mode = "600";
        };
        id_ed25519_pub = {
          file = "${inputs.mysecrets}/secrets/laptop/id_ed25519_pub.age";
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
