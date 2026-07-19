{
  lib,
  config,
  ...
}: {
  # Only the boot SD card goes through disko. The 9 array drives and 2
  # cache NVMe drives already hold real data and existing filesystems --
  # they're mounted directly via plain fileSystems entries in storage.nix
  # instead, so nothing here can accidentally reformat them.

  options.crate.storage.crateServer.bootDevice = lib.mkOption {
    type = lib.types.str;
    default = "/dev/mmcblk0";
    description = "Boot device (a microSD card on real hardware).";
  };

  config.disko.devices = {
    disk = {
      boot = {
        type = "disk";
        device = config.crate.storage.crateServer.bootDevice;
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "fmask=0022"
                  "dmask=0022"
                ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = ["-f"];
                subvolumes = {
                  "@root" = {
                    mountpoint = "/";
                    mountOptions = ["compress=zstd"];
                  };
                  "@home" = {
                    mountpoint = "/home";
                    mountOptions = ["compress=zstd"];
                  };
                  "@var" = {
                    mountpoint = "/var";
                    mountOptions = ["compress=zstd"];
                  };
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = ["compress=zstd" "noatime"];
                  };
                  "@persist" = {
                    mountpoint = "/persist";
                    mountOptions = ["compress=zstd"];
                  };
                  "@swap" = {
                    mountpoint = "/swap";
                    mountOptions = ["noatime"];
                    swap.swapfile.size = "8G";
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
