{...}: {
  flake.modules.nixos.beszel = {
    config,
    pkgs,
    ...
  }: {
    environment.systemPackages = [pkgs.beszel];
    services.beszel.agent = {
      enable = true;
      environmentFile = config.age.secrets.beszel-env.path;
    };
  };
}
