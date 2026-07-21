{...}: {
  flake.modules.nixos.unraid-compose = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.crate.unraidCompose;
    repoDir = "/persist/unraid-compose";
    envPath = config.age.secrets.komodo-env.path;

    # A single no-spaces path for GIT_SSH_COMMAND -- systemd's Environment=
    # splits an unquoted value on whitespace into separate assignments, so
    # "ssh -i <path> -o ..." as one string silently drops everything after
    # the binary path. A wrapper script sidesteps that entirely.
    gitSshWrapper = pkgs.writeShellScript "unraid-compose-git-ssh" ''
      exec ${pkgs.openssh}/bin/ssh -i ${config.age.secrets.deployKey.path} -o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new "$@"
    '';

    komodoBringup =
      if cfg.enableKomodo
      then ''
        if [ -f "${repoDir}/komodo/compose.yaml" ]; then
          ln -sf "${envPath}" "${repoDir}/komodo/.env"
          ${pkgs.docker}/bin/docker compose -p komodo -f "${repoDir}/komodo/compose.yaml" --env-file "${envPath}" up -d
        else
          echo "komodo/compose.yaml not in the repo yet, skipping Komodo"
        fi
      ''
      else ''
        echo "Komodo disabled via crate.unraidCompose.enableKomodo, skipping"
      '';
  in {
    options.crate.unraidCompose.enableKomodo = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Whether unraid-compose should also bring up Komodo (when
        komodo/compose.yaml exists in the repo). Set false on hosts that
        should only run Arcane, e.g. rehearsal VMs not yet ready for
        Komodo. Doesn't stop an already-running Komodo stack -- this only
        gates future bring-up.
      '';
    };

    systemd.tmpfiles.rules = [
      "d /persist/unraid-compose 0755 matt users -"
      "d /mnt/cache_appdata/appdata/komodo/postgres-data 0755 root root -"
      "d /mnt/cache_appdata/appdata/komodo/ferretdb-state 0755 root root -"
      "d /mnt/cache_appdata/appdata/komodo/keys 0755 root root -"
      "d /mnt/cache_appdata/appdata/komodo/backups 0755 root root -"
      "d /mnt/cache_appdata/appdata/komodo/komodo-data 0755 root root -"
    ];

    systemd.services.unraid-compose = {
      description = "Sync cratedev/crate-server and bring up Arcane + Komodo";
      after = ["docker.service" "network-online.target" "mnt-user-appdata.mount"];
      wants = ["network-online.target"];
      requires = ["docker.service"];
      wantedBy = ["multi-user.target"];

      # Retries on failure: network-online.target doesn't guarantee DNS is
      # actually usable yet (seen at boot with DHCP/NetworkManager still
      # settling), and this shouldn't have to wait a full hour to recover
      # from a transient failure like that.
      startLimitIntervalSec = 600;
      startLimitBurst = 6;

      serviceConfig = {
        Type = "oneshot";
        User = "matt";
        Environment = "GIT_SSH_COMMAND=${gitSshWrapper}";
        Restart = "on-failure";
        RestartSec = "20s";
      };

      script = ''
        set -euo pipefail

        if [ -d "${repoDir}/.git" ]; then
          ${pkgs.git}/bin/git -C "${repoDir}" pull --ff-only
        else
          ${pkgs.git}/bin/git clone git@github.com:cratedev/crate-server.git "${repoDir}"
        fi

        ${pkgs.docker}/bin/docker compose -p arcane -f "${repoDir}/arcane/compose.yaml" up -d

        ${komodoBringup}
      '';
    };

    systemd.timers.unraid-compose = {
      description = "Periodically resync cratedev/crate-server and reapply compose state";
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = "hourly";
        Persistent = true;
      };
    };
  };
}
