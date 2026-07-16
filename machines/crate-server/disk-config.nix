{
  # Simulates the full unRAID setup on a single 500GB SSD.
  # Set device below to the real SSD path (check with `lsblk`).

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

      test-storage = {
        type = "disk";
        device = "/dev/sda111";
        content = {
          type = "gpt";
          partitions = {
            cache_appdata = {
              size = "100G";
              content = {
                type = "filesystem";
                format = "xfs";
                mountpoint = "/mnt/cache_appdata";
                mountOptions = ["defaults"];
              };
            };

            cache_data = {
              size = "100G";
              content = {
                type = "filesystem";
                format = "xfs";
                mountpoint = "/mnt/cache_data";
                mountOptions = ["defaults"];
              };
            };

            disk1 = {
              size = "100G";
              content = {
                type = "filesystem";
                format = "xfs";
                mountpoint = "/mnt/disk1";
                mountOptions = ["defaults"];
              };
            };

            disk2 = {
              size = "100G";
              content = {
                type = "filesystem";
                format = "xfs";
                mountpoint = "/mnt/disk2";
                mountOptions = ["defaults"];
              };
            };

            disk3 = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "xfs";
                mountpoint = "/mnt/disk3";
                mountOptions = ["defaults"];
              };
            };
          };
        };
      };
    };
  };
}
