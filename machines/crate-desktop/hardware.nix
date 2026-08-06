{
  config,
  lib,
  modulesPath,
  pkgs,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (import ../rollback-subvolumes.nix "/dev/disk/by-uuid/84be45b9-f3a6-483c-b26d-201456283506")
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = ["kvm-amd"];
    extraModulePackages = [];
    kernelParams = [
      "amdgpu.ppfeaturemask=0xfffd7fff"
    ];
    initrd = {
      availableKernelModules = ["nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod"];
      kernelModules = [];

      systemd.enable = true;
    };
  };

  fileSystems = {
    "/home".neededForBoot = true;
    "/var".neededForBoot = true;
    "/persist".neededForBoot = true;
  };

  zramSwap.enable = true;

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
