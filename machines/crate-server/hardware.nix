{
  config,
  lib,
  modulesPath,
  pkgs,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (import ../rollback-subvolumes.nix "/dev/disk/by-label/nixos")
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = ["kvm-intel"];
    extraModulePackages = [];
    initrd = {
      # SD-card host controller module (e.g. sdhci_pci/sdhci_acpi) isn't
      # listed yet -- this file was hand-written, not generated from the
      # real hardware. Regenerate with `nixos-generate-config` against the
      # actual box before deploying, since booting from mmcblk0 needs it.
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
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Intel Quick Sync (UHD 730) for hardware transcoding, used by the
  # Jellyfin container via /dev/dri passthrough.
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [intel-media-driver vaapi-intel-hybrid libvdpau-va-gl];
  };
}
