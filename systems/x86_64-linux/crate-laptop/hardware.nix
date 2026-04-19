{
  config,
  lib,
  modulesPath,
  inputs,
  pkgs,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    inputs.nixos-hardware.nixosModules.dell-xps-15-9510
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = [];
    extraModulePackages = [];
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "thunderbolt"
        "vmd"
        "nvme"
        "rtsx_pci_sdmmc"
      ];
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
            mount -o subvol=/ /dev/nvme1n1p2 /btrfs_tmp

            delete_subvolume_recursively() {
            	IFS=$'\n'
            	for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
            		delete_subvolume_recursively "/btrfs_tmp/$i"
            	done
            	btrfs subvolume delete "$1"
            }

            [[ -e /btrfs_tmp/@root ]] && delete_subvolume_recursively /btrfs_tmp/@root
            [[ -e /btrfs_tmp/@home ]] && delete_subvolume_recursively /btrfs_tmp/@home
            [[ -e /btrfs_tmp/@var ]]  && delete_subvolume_recursively /btrfs_tmp/@var

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
}
