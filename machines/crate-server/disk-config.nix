{
  # Only the boot SD card goes through disko. The 9 array drives and 2
  # cache NVMe drives already hold real data and existing filesystems --
  # they're mounted directly via plain fileSystems entries in storage.nix
  # instead, so nothing here can accidentally reformat them.

  disko.devices = {
    disk = {
      # Boot drive - microSD card
      boot = {
        type = "disk";
        device = "/dev/mmcblk0";
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
