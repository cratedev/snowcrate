{self, ...}: {
  flake.modules.nixos.snowcrate-status = {
    config,
    pkgs,
    ...
  }: {
    environment.etc."snowcrate-info".text = ''
      host: ${config.networking.hostName}
      git rev: ${self.rev or "dirty"}
    '';

    environment.systemPackages = [(import ../../../packages/snowcrate-status {inherit pkgs;})];
  };
}
