{
  config,
  lib,
  pkgs,
  ...
}: {
  # TEST CONFIGURATION
  # This uses the partitions from disk-config-test.nix
  # Simulates: cache_appdata, cache_data, and 3-disk array
  
  # Install required packages
  environment.systemPackages = with pkgs; [
    mergerfs
    mergerfs-tools
    rsync
    (writeScriptBin "nixos-mover" ''
      #!/usr/bin/env bash
      exec /etc/nixos-mover.sh "$@"
    '')
  ];

  # Note: The actual mounts are handled by Disko from disk-config-test.nix
  # We only need to configure MergerFS here
  
  # MergerFS pool combining cache_data + all array drives
  # This replicates unRAID's /mnt/user view
  # Cache is listed first so writes go to cache first (like unRAID)
  fileSystems."/mnt/user" = {
    device = "/mnt/cache_data:/mnt/disk1:/mnt/disk2:/mnt/disk3";
    fsType = "fuse.mergerfs";
    options = [
      "defaults"
      "allow_other"
      "use_ino"
      "cache.files=partial"
      "dropcacheonclose=true"
      "category.create=ff" # ff = first found with space (writes to cache first)
      "moveonenospc=true" # Move to array if cache fills up
      "minfreespace=5G" # Keep 5GB free on cache (smaller for testing)
      "fsname=mergerfs:user"
    ];
  };

  # Create a mover script that replicates unRAID's mover functionality
  environment.etc."nixos-mover.sh" = {
    text = ''
      #!/usr/bin/env bash
      # NixOS Mover - Replicates unRAID's mover functionality
      # TEST VERSION - Moves data from /mnt/cache_data to array drives

      set -euo pipefail

      CACHE_DIR="/mnt/cache_data"
      USER_DIR="/mnt/user"
      LOG_FILE="/var/log/nixos-mover.log"

      log() {
          echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
      }

      log "Starting mover process..."

      # Check if cache has data to move
      CACHE_USAGE=$(df "$CACHE_DIR" | awk 'NR==2 {print $5}' | sed 's/%//')
      log "Cache usage: $CACHE_USAGE%"

      # For testing, use a lower threshold (50% instead of 80%)
      if [ "$CACHE_USAGE" -lt 50 ]; then
          log "Cache usage below threshold (50%), skipping move"
          exit 0
      fi

      # Find all files/directories in cache_data
      cd "$CACHE_DIR" || exit 1

      # Move data to array via the merged filesystem
      # This works because mergerfs will automatically distribute to array drives
      # when writing through /mnt/user

      find . -mindepth 1 -maxdepth 1 -type d | while read -r dir; do
          dir_name=$(basename "$dir")

          # Skip special directories
          if [[ "$dir_name" == "appdata" ]] || [[ "$dir_name" == "domains" ]] || [[ "$dir_name" == "system" ]]; then
              log "Skipping $dir_name (pinned to cache)"
              continue
          fi

          log "Moving $dir_name from cache to array..."

          # Use rsync to move with verification
          if rsync -aP --remove-source-files "$CACHE_DIR/$dir_name/" "$USER_DIR/$dir_name/"; then
              # Remove empty directories after successful move
              find "$CACHE_DIR/$dir_name" -type d -empty -delete
              log "Successfully moved $dir_name"
          else
              log "ERROR: Failed to move $dir_name"
          fi
      done

      log "Mover process completed"
    '';
    mode = "0755";
  };

  # Systemd service for mover
  systemd = {
    services.nixos-mover = {
      description = "NixOS Mover - Move data from cache to array";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "/etc/nixos-mover.sh";
        Nice = 19;
        IOSchedulingClass = "idle";
      };
    };

    # Systemd timer to run mover daily at 3 AM
    timers.nixos-mover = {
      description = "Run NixOS mover daily";
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = "03:00";
        Persistent = true;
      };
    };

    # Create necessary directories (Disko creates mount points, but this ensures they exist)
    tmpfiles.rules = [
      "d /mnt/cache_appdata 0755 root root -"
      "d /mnt/cache_data 0755 root root -"
      "d /mnt/disk1 0755 root root -"
      "d /mnt/disk2 0755 root root -"
      "d /mnt/disk3 0755 root root -"
      "d /mnt/user 0755 root root -"
      "d /var/log 0755 root root -"
    ];
  };
}
