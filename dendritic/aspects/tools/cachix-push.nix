{...}: {
  flake.modules.nixos.cachix-push = {
    config,
    pkgs,
    ...
  }: {
    environment.systemPackages = [pkgs.cachix];

    systemd.services.cachix-watch-store = {
      description = "Push newly built store paths to the snowcrate Cachix cache";
      after = ["network-online.target"];
      wants = ["network-online.target"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        ExecStart = "${pkgs.cachix}/bin/cachix watch-store snowcrate";
        EnvironmentFile = config.age.secrets.cachix-env.path;
        Restart = "on-failure";
        RestartSec = "10s";
        User = "matt";
      };
    };
  };
}
