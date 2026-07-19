{...}: {
  # Disabled for now -- Periphery runs as a docker container to match the
  # current unraid setup. This is here so switching to the native agent
  # later is a one-line flip instead of a from-scratch setup.
  flake.modules.nixos.komodo-periphery = {...}: {
    services.komodo-periphery = {
      enable = false;
      rootDirectory = "/mnt/cache_appdata/appdata/komodo-periphery";
    };
  };
}
