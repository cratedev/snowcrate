{...}: {
  flake.modules.homeManager.git-sync-check = {
    config,
    pkgs,
    ...
  }: {
    systemd.user.services.git-sync-check = {
      Unit.Description = "Notify if snowcrate is behind origin/master";
      Service = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "git-sync-check" ''
          set -euo pipefail
          cd "${config.home.homeDirectory}/snowcrate"
          ${pkgs.git}/bin/git fetch --quiet origin master
          behind=$(${pkgs.git}/bin/git rev-list --count HEAD..origin/master)
          if [ "$behind" -gt 0 ]; then
            ${pkgs.libnotify}/bin/notify-send "snowcrate" "$behind commit(s) behind origin/master"
          fi
        '';
      };
    };

    systemd.user.timers.git-sync-check = {
      Unit.Description = "Periodic snowcrate sync check";
      Timer = {
        OnStartupSec = "10m";
        OnUnitActiveSec = "4h";
      };
      Install.WantedBy = ["timers.target"];
    };
  };
}
