{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.cli.fish;
in {
  options.${namespace}.cli.fish = with types; {
    enable = mkBoolOpt false "Enable/disable fish";
  };

  config = mkIf cfg.enable {
    programs = {
      fish = {
        enable = true;
        interactiveShellInit = ''
          set fish_greeting # Disable greeting
        '';
        functions = {
          #jf = "just -f ~/snowcrate/Justfile $argv";
          ntest = "cd $NH_FLAKE && just test";
          nswitch = "cd $NH_FLAKE && just switch";
          rtest = "cd $NH_FLAKE && just remotetest";
          rswitch = "cd $NH_FLAKE && just remoteswitch";
          ts = "sudo tailscale up --accept-routes";
        };
      };
    };
  };
}
