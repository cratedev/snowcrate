{
  config,
  lib,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = ["xhci_pci" "thunderbolt" "vmd" "nvme" "rtsx_pci_sdmmc"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = [];
  boot.extraModulePackages = [];

  boot.initrd.postResumeCommands = lib.mkAfter ''
    mkdir -p /btrfs_tmp
    mount -o subvol=/ /dev/disk/by-uuid/e7fc8953-54dd-4581-a279-029da0da2d25 /btrfs_tmp

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

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/e7fc8953-54dd-4581-a279-029da0da2d25";
    fsType = "btrfs";
    #    neededForBoot = true;
    options = ["subvol=@root" "compress=zstd"];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/e7fc8953-54dd-4581-a279-029da0da2d25";
    neededForBoot = true;
    fsType = "btrfs";
    options = ["subvol=@home" "compress=zstd"];
  };

  fileSystems."/var" = {
    device = "/dev/disk/by-uuid/e7fc8953-54dd-4581-a279-029da0da2d25";
    neededForBoot = true;
    fsType = "btrfs";
    options = ["subvol=@var" "compress=zstd"];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/e7fc8953-54dd-4581-a279-029da0da2d25";
    fsType = "btrfs";
    options = ["subvol=@nix" "compress=zstd" "noatime"];
  };

  fileSystems."/persist" = {
    device = "/dev/disk/by-uuid/e7fc8953-54dd-4581-a279-029da0da2d25";
    neededForBoot = true;
    fsType = "btrfs";
    options = ["subvol=@persist" "compress=zstd"];
  };

  fileSystems."/swap" = {
    device = "/dev/disk/by-uuid/e7fc8953-54dd-4581-a279-029da0da2d25";
    fsType = "btrfs";
    options = ["subvol=@swap" "noatime"];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/8E9E-2EB4";
    fsType = "vfat";
    options = ["fmask=0022" "dmask=0022"];
  };

  swapDevices = [
    {device = "/swap/swapfile";}
  ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp0s20f3.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
