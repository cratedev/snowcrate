{
  config,
  lib,
  modulesPath,
  pkgs,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
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

      systemd = {
        enable = true;
        services.rollback = {
          description = "Rollback BTRFS subvolumes";
          wantedBy = ["initrd.target"];
          after = ["initrd-root-device.target"];
          before = ["sysroot.mount"];
          unitConfig.DefaultDependencies = "no";
          serviceConfig.Type = "oneshot";
          script = ''
            mkdir -p /btrfs_tmp
            mount -o subvol=/ /dev/disk/by-label/nixos /btrfs_tmp

            delete_subvolume_recursively() {
              IFS=$'\n'
              for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
                delete_subvolume_recursively "/btrfs_tmp/$i"
              done
              btrfs subvolume delete "$1"
            }

            [[ -e /btrfs_tmp/@root ]] && delete_subvolume_recursively /btrfs_tmp/@root
            [[ -e /btrfs_tmp/@home ]] && delete_subvolume_recursively /btrfs_tmp/@home
            [[ -e /btrfs_tmp/@var ]] && delete_subvolume_recursively /btrfs_tmp/@var

            btrfs subvolume create /btrfs_tmp/@root
            btrfs subvolume create /btrfs_tmp/@home
            btrfs subvolume create /btrfs_tmp/@var
            umount /btrfs_tmp
          '';
        };
      };
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
