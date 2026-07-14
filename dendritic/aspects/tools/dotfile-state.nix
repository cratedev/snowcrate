{...}: {
  flake.modules.homeManager.dotfile-state = {pkgs, ...}: let
    # Single source of truth for what dotfile-state-capture backs up --
    # also fed to dotfile-state-check so it can tell you what's persisted
    # but NOT in this list, rather than maintaining a second copy that
    # could silently drift from the capture script.
    capturedPaths = [
      ".config/DankMaterialShell"
      ".local/state/DankMaterialShell"
      ".config/vesktop"
      ".config/obsidian"
      ".config/YouTube Music Desktop App"
    ];

    # Paths dotfile-state-check should never flag, because they're known
    # to be regenerated deterministically from something that's already
    # persisted/captured elsewhere -- not because they're unimportant.
    ignoredPaths = [
      # DMS writes these fresh every boot from its own settings.json,
      # which lives under .config/DankMaterialShell (already captured).
      ".config/niri/dms"
    ];

    capture = import ../../../packages/dotfile-state-capture {inherit pkgs capturedPaths;};
    restore = import ../../../packages/dotfile-state-restore {inherit pkgs;};
    check = import ../../../packages/dotfile-state-check {inherit pkgs capturedPaths ignoredPaths;};
  in {
    home.packages = [capture restore check];

    systemd.user.services.dotfile-state-capture = {
      Unit.Description = "Capture and push persisted-but-not-declared app config state";
      Service = {
        Type = "oneshot";
        ExecStart = "${capture}/bin/dotfile-state-capture";
      };
    };

    systemd.user.timers.dotfile-state-capture = {
      Unit.Description = "Weekly dotfile-state capture";
      Timer = {
        OnCalendar = "weekly";
        Persistent = true;
      };
      Install.WantedBy = ["timers.target"];
    };
  };
}
