{...}: {
  flake.modules.nixos.deploy-test-vm = {pkgs, ...}: {
    environment.systemPackages = [
      (import ../../../packages/deploy-test-vm {inherit pkgs;})
      pkgs.qemu
    ];

    users.users.matt.extraGroups = ["kvm"];
  };
}
