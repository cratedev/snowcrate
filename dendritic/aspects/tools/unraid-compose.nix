{...}: {
  flake.modules.nixos.unraid-compose = {
    config,
    pkgs,
    ...
  }: let
    repoDir = "/persist/unraid-compose";
    envPath = config.age.secrets.komodo-env.path;
  in {
    systemd.tmpfiles.rules = [
      "d /persist/unraid-compose 0755 matt users -"
      "d /mnt/cache_appdata/appdata/komodo/postgres-data 0755 root root -"
      "d /mnt/cache_appdata/appdata/komodo/ferretdb-state 0755 root root -"
      "d /mnt/cache_appdata/appdata/komodo/keys 0755 root root -"
      "d /mnt/cache_appdata/appdata/komodo/backups 0755 root root -"
      "d /mnt/cache_appdata/appdata/komodo/komodo-data 0755 root root -"
    ];

    systemd.services.unraid-compose = {
      description = "Sync cratedev/unraid and bring up Arcane + Komodo";
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
        Environment = "GIT_SSH_COMMAND=${pkgs.openssh}/bin/ssh -i ${config.age.secrets.deployKey.path} -o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new";
        Restart = "on-failure";
        RestartSec = "20s";
      };

      script = ''
        set -euo pipefail

        if [ -d "${repoDir}/.git" ]; then
          ${pkgs.git}/bin/git -C "${repoDir}" pull --ff-only
        else
          ${pkgs.git}/bin/git clone git@github.com:cratedev/unraid.git "${repoDir}"
        fi

        ${pkgs.docker}/bin/docker compose -p arcane -f "${repoDir}/arcane/compose.yaml" up -d

        if [ -f "${repoDir}/komodo/compose.yaml" ]; then
          ln -sf "${envPath}" "${repoDir}/komodo/.env"
          ${pkgs.docker}/bin/docker compose -p komodo -f "${repoDir}/komodo/compose.yaml" --env-file "${envPath}" up -d
        else
          echo "komodo/compose.yaml not in the repo yet, skipping Komodo"
        fi
      '';
    };

    systemd.timers.unraid-compose = {
      description = "Periodically resync cratedev/unraid and reapply compose state";
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = "hourly";
        Persistent = true;
      };
    };
  };
}
