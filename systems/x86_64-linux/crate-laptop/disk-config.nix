{
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
}
