{...}: {
  # A tiny HTTP listener that spawns apps in the real niri session, for
  # Companion buttons to hit. Companion runs in a Docker container, so
  # it has no access to the host's Wayland session -- this bridges that
  # gap: Companion does an HTTP Request action, this listener runs the
  # actual `uwsm app -- <command>` on the host, same way niri's own
  # spawn-at-startup entries launch apps.
  #
  # Allowlist only, by design: this listens on the LAN (reachable from
  # the Companion container and anything else on the network), so it
  # deliberately maps a fixed set of names to fixed commands rather than
  # accepting an arbitrary command to run.
  flake.modules.homeManager.app-spawn-listener = {pkgs, ...}: let
    port = 9797;

    apps = {
      zen = ["zen-beta"];
    };

    listener = pkgs.writers.writePython3Bin "app-spawn-listener" {flakeIgnore = ["E231"];} ''
      import http.server
      import re
      import subprocess

      APPS = ${builtins.toJSON apps}


      class Handler(http.server.BaseHTTPRequestHandler):
          def do_GET(self):
              m = re.fullmatch(r"/spawn/([a-zA-Z0-9_-]+)", self.path)
              name = m.group(1) if m else None
              if name not in APPS:
                  self.send_response(404)
                  self.end_headers()
                  self.wfile.write(b"unknown app\n")
                  return
              subprocess.Popen(["uwsm", "app", "--", *APPS[name]])
              self.send_response(200)
              self.end_headers()
              self.wfile.write(b"spawned\n")


      if __name__ == "__main__":
          http.server.HTTPServer(("0.0.0.0", ${toString port}), Handler).serve_forever()
    '';
  in {
    home.packages = [listener];

    systemd.user.services.app-spawn-listener = {
      Unit = {
        Description = "HTTP listener that spawns apps on the host, for Companion buttons";
        After = ["graphical-session.target"];
        PartOf = ["graphical-session.target"];
      };
      Service = {
        ExecStart = "${listener}/bin/app-spawn-listener";
        Restart = "on-failure";
        RestartSec = "5s";
      };
      Install.WantedBy = ["graphical-session.target"];
    };
  };
}
