{inputs, ...}: {
  flake.modules.nixos.deploy = {pkgs, ...}: {
    environment.systemPackages = [
      (import ../../../packages/deploy {inherit pkgs inputs;})
    ];
  };
}
