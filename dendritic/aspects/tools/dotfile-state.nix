{...}: {
  flake.modules.homeManager.dotfile-state = {pkgs, ...}: let
    capture = import ../../../packages/dotfile-state-capture {inherit pkgs;};
    restore = import ../../../packages/dotfile-state-restore {inherit pkgs;};
  in {
    home.packages = [capture restore];

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
