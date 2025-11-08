{
  config,
  lib,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    kernelModules = ["kvm-amd"];
    extraModulePackages = [];
    initrd = {
      availableKernelModules = ["nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod"];
      kernelModules = [];

      postResumeCommands = lib.mkAfter ''
        mkdir -p /btrfs_tmp
        mount -o subvol=/ /dev/disk/by-uuid/84be45b9-f3a6-483c-b26d-201456283506 /btrfs_tmp

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
