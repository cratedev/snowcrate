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

      serviceConfig = {
        Type = "oneshot";
        User = "matt";
        Environment = "GIT_SSH_COMMAND=${pkgs.openssh}/bin/ssh -i ${config.age.secrets.deployKey.path} -o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new";
      };

      script = ''
        set -euo pipefail

        if [ -d "${repoDir}/.git" ]; then
          ${pkgs.git}/bin/git -C "${repoDir}" pull --ff-only
        else
          ${pkgs.git}/bin/git clone git@github.com:cratedev/unraid.git "${repoDir}"
        fi

        ln -sf "${envPath}" "${repoDir}/komodo/.env"

        ${pkgs.docker}/bin/docker compose -p arcane -f "${repoDir}/arcane/compose.yaml" up -d
        ${pkgs.docker}/bin/docker compose -p komodo -f "${repoDir}/komodo/compose.yaml" --env-file "${envPath}" up -d
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
