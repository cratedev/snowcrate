{
  # TEST CONFIGURATION
  # This uses a single 500GB SSD to simulate your full unRAID setup
  # Partitions: cache_appdata (100GB), cache_data (100GB), disk1-3 (100GB each)
  #
  # IMPORTANT: Change /dev/sda to your actual 500GB SSD device path
  # Run `lsblk` to identify the correct device

  disko.devices = {
    disk = {
      # Boot drive - microSD card
      boot = {
        type = "disk";
        device = "/dev/mmcblk0"; # Your microSD device
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

      # TEST SSD - 500GB drive that simulates your entire storage setup
      test-storage = {
        type = "disk";
        device = "/dev/sda111"; # CHANGE THIS to your 500GB SSD device path
        content = {
          type = "gpt";
          partitions = {
            # Simulate cache_appdata (Docker/VMs) - 100GB
            cache_appdata = {
              size = "100G";
              content = {
                type = "filesystem";
                format = "xfs";
                mountpoint = "/mnt/cache_appdata";
                mountOptions = ["defaults"];
              };
            };

            # Simulate cache_data (fast write cache) - 100GB
            cache_data = {
              size = "100G";
              content = {
                type = "filesystem";
                format = "xfs";
                mountpoint = "/mnt/cache_data";
                mountOptions = ["defaults"];
              };
            };

            # Simulate array disk1 - 100GB
            disk1 = {
              size = "100G";
              content = {
                type = "filesystem";
                format = "xfs";
                mountpoint = "/mnt/disk1";
                mountOptions = ["defaults"];
              };
            };

            # Simulate array disk2 - 100GB
            disk2 = {
              size = "100G";
              content = {
                type = "filesystem";
                format = "xfs";
                mountpoint = "/mnt/disk2";
                mountOptions = ["defaults"];
              };
            };

            # Simulate array disk3 - remaining space (~100GB)
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
