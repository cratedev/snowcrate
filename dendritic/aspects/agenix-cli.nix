{inputs, ...}: {
  # Installs the agenix CLI. Per-host secrets (age.secrets.*) are declared
  # directly in each host's own module, not here.
  flake.modules.nixos.agenix-cli = {...}: {
    imports = [inputs.agenix.nixosModules.default];
    environment.systemPackages = [inputs.agenix.packages.x86_64-linux.default];
  };
}
