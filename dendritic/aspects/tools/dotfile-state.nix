{...}: {
  flake.modules.homeManager.dotfile-state = {pkgs, ...}: let
    # Shared by dotfile-state-capture and dotfile-state-check.
    capturedPaths = [
      ".config/DankMaterialShell"
      ".local/state/DankMaterialShell"
      ".config/noctalia"
      ".local/state/noctalia"
      ".config/vesktop"
      ".config/obsidian"
      ".config/YouTube Music Desktop App"
    ];

    # Paths dotfile-state-check ignores as regenerated from something
    # already captured elsewhere.
    ignoredPaths = [
      # Regenerated from .config/DankMaterialShell/settings.json.
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
