{
  pkgs,
  lib,
  ...
}: let
  # Array disks: no parity, pooled with mergerfs. Referenced by-id since
  # /dev/sdX ordering isn't guaranteed stable across boots.
  arrayDisks = {
    disk1 = "ata-WDC_WD120EMFZ-11A6JA0_9KGEW2KL";
    disk2 = "ata-WDC_WD140EFGX-68B0GN0_9RHGR0WL";
    disk3 = "ata-WDC_WD80EMAZ-00WJTA0_1EHEXVJZ";
    disk4 = "ata-WDC_WD80EMAZ-00WJTA0_1EHYKNVZ";
    disk5 = "ata-WDC_WD80EMAZ-00WJTA0_7HJW1EVF";
    disk6 = "ata-WDC_WD80EMAZ-00WJTA0_7HK5WMHN";
    disk7 = "ata-WDC_WD80EMAZ-00WJTA0_7HKHWTEJ";
    disk8 = "ata-WDC_WD80EZAZ-11TDBA0_1SHKTUDZ";
    disk9 = "ata-WDC_WD80EZAZ-11TDBA0_1SJ9S6EZ";
  };

  cacheAppdataId = "nvme-WD_Blue_SN580_1TB_24154H417383";
  cacheDataId = "nvme-WD_Blue_SN580_1TB_24154G400745";

  byId = id: "/dev/disk/by-id/${id}-part1";

  arrayMountpoints = map (name: "/mnt/array/${name}") (builtins.attrNames arrayDisks);

  # Shares that live permanently on Cache_appdata -- no mover involved.
  pinnedShares = ["appdata" "backups" "dmz" "domains" "isos" "logs" "system"];

  physicalDisks =
    {
      "/mnt/cache_appdata" = byId cacheAppdataId;
      "/mnt/cache_data" = byId cacheDataId;
    }
    // lib.listToAttrs (map (name: lib.nameValuePair "/mnt/array/${name}" (byId arrayDisks.${name})) (builtins.attrNames arrayDisks));

  physicalFileSystems =
    lib.mapAttrs (_: device: {
      inherit device;
      fsType = "xfs";
      options = ["defaults" "nofail"];
    })
    physicalDisks;

  pinnedShareFileSystems = lib.listToAttrs (map (share:
    lib.nameValuePair "/mnt/user/${share}" {
      device = "/mnt/cache_appdata/${share}";
      fsType = "none";
      options = [
        "bind"
        "nofail"
        "x-systemd.requires-mounts-for=/mnt/cache_appdata"
      ];
    })
    pinnedShares);

  dataMergerfs = {
    "/mnt/user/data" = {
      device = lib.concatStringsSep ":" (["/mnt/cache_data/data"] ++ map (m: "${m}/data") arrayMountpoints);
      fsType = "fuse.mergerfs";
      options =
        [
          "defaults"
          "nofail"
          "allow_other"
          "use_ino"
          "cache.files=partial"
          "dropcacheonclose=true"
          "category.create=ff" # new writes land on cache_data first
          "moveonenospc=true" # overflow straight to array if cache fills up
          "minfreespace=20G"
          "fsname=mergerfs:data"
        ]
        ++ map (m: "x-systemd.requires-mounts-for=${m}") (["/mnt/cache_data"] ++ arrayMountpoints);
    };
  };
in {
  environment.systemPackages = with pkgs; [
    mergerfs
    mergerfs-tools
    rsync
    psmisc # fuser, used by the mover's open-file check
    (writeScriptBin "nixos-mover" ''
      #!/usr/bin/env bash
      exec /etc/nixos-mover.sh "$@"
    '')
  ];

  fileSystems = physicalFileSystems // pinnedShareFileSystems // dataMergerfs;

  environment.etc."nixos-mover.sh" = {
    text = ''
      #!/usr/bin/env bash
      # Moves data/ files from Cache_data to whichever array disk has the
      # most free space, skipping anything currently open (e.g. actively
      # streaming in Jellyfin). Mirrors unRAID's mover + high-water
      # allocator behavior.

      set -euo pipefail

      CACHE_DIR="/mnt/cache_data/data"
      ARRAY_DISKS=(${lib.concatStringsSep " " arrayMountpoints})
      LOG_FILE="/var/log/nixos-mover.log"
      THRESHOLD=''${NIXOS_MOVER_THRESHOLD:-80}

      log() {
          echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
      }

      cache_usage=$(df --output=pcent "$CACHE_DIR" | tail -1 | tr -dc '0-9')
      log "Cache usage: ''${cache_usage}%"

      if [ "$cache_usage" -lt "$THRESHOLD" ]; then
          log "Cache usage below threshold ($THRESHOLD%), skipping move"
          exit 0
      fi

      most_free_array_disk() {
          local best="" best_avail=-1
          for disk in "''${ARRAY_DISKS[@]}"; do
              avail=$(df --output=avail "$disk" | tail -1 | tr -dc '0-9')
              if [ "$avail" -gt "$best_avail" ]; then
                  best="$disk"
                  best_avail="$avail"
              fi
          done
          echo "$best"
      }

      log "Starting mover process..."
      moved=0 skipped=0

      while IFS= read -r -d "" file; do
          rel="''${file#"$CACHE_DIR"/}"

          if fuser -s "$file" 2>/dev/null; then
              log "Skipping (open): $rel"
              skipped=$((skipped + 1))
              continue
          fi

          dest_disk=$(most_free_array_disk)
          dest="$dest_disk/data/$rel"
          mkdir -p "$(dirname "$dest")"

          if rsync -a --remove-source-files "$file" "$dest"; then
              moved=$((moved + 1))
          else
              log "ERROR: Failed to move $rel"
          fi
      done < <(find "$CACHE_DIR" -mindepth 1 -type f -print0)

      find "$CACHE_DIR" -mindepth 1 -type d -empty -delete

      log "Mover process completed: $moved moved, $skipped skipped (open)"
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

    # Ensures mount points and per-disk share directories exist; the
    # physical disks may not have these until first created.
    tmpfiles.rules =
      ["d /mnt/user 0755 root root -" "d /var/log 0755 root root -"]
      ++ map (mp: "d ${mp} 0755 root root -") (["/mnt/cache_appdata" "/mnt/cache_data"] ++ arrayMountpoints)
      ++ map (share: "d /mnt/cache_appdata/${share} 0755 root root -") pinnedShares
      ++ ["d /mnt/cache_data/data 0755 root root -"]
      ++ map (mp: "d ${mp}/data 0755 root root -") arrayMountpoints;
  };
}
