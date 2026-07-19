{inputs, ...}: {
  flake.modules.nixos.noctalia-greeter = {...}: {
    imports = [inputs.noctalia-greeter.nixosModules.default];

    # Which session starts after a successful login -- independent of
    # which greeter software presents the login screen itself.
    services.displayManager.defaultSession = "niri-uwsm";

    programs.noctalia-greeter.enable = true;
  };
}
