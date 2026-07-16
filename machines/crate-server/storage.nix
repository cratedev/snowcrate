{
  config,
  lib,
  pkgs,
  ...
}: {
  # Uses partitions from disk-config-test.nix: cache_appdata, cache_data,
  # 3-disk array.
  environment.systemPackages = with pkgs; [
    mergerfs
    mergerfs-tools
    rsync
    (writeScriptBin "nixos-mover" ''
      #!/usr/bin/env bash
      exec /etc/nixos-mover.sh "$@"
    '')
  ];

  # Mounts come from Disko via disk-config-test.nix; this configures
  # MergerFS. Cache listed first so writes land there first.
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

  environment.etc."nixos-mover.sh" = {
    text = ''
      #!/usr/bin/env bash
      # Moves data from /mnt/cache_data to array drives.

      set -euo pipefail

      CACHE_DIR="/mnt/cache_data"
      USER_DIR="/mnt/user"
      LOG_FILE="/var/log/nixos-mover.log"

      log() {
          echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
      }

      log "Starting mover process..."

      CACHE_USAGE=$(df "$CACHE_DIR" | awk 'NR==2 {print $5}' | sed 's/%//')
      log "Cache usage: $CACHE_USAGE%"

      # Threshold lowered to 50% for testing (production would use 80%).
      if [ "$CACHE_USAGE" -lt 50 ]; then
          log "Cache usage below threshold (50%), skipping move"
          exit 0
      fi

      cd "$CACHE_DIR" || exit 1

      # mergerfs distributes writes through /mnt/user to array drives.
      find . -mindepth 1 -maxdepth 1 -type d | while read -r dir; do
          dir_name=$(basename "$dir")

          if [[ "$dir_name" == "appdata" ]] || [[ "$dir_name" == "domains" ]] || [[ "$dir_name" == "system" ]]; then
              log "Skipping $dir_name (pinned to cache)"
              continue
          fi

          log "Moving $dir_name from cache to array..."

          if rsync -aP --remove-source-files "$CACHE_DIR/$dir_name/" "$USER_DIR/$dir_name/"; then
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

    timers.nixos-mover = {
      description = "Run NixOS mover daily";
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = "03:00";
        Persistent = true;
      };
    };

    # Ensures mount points exist; Disko may not create them all.
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
