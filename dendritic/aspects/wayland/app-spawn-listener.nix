{...}: {
  # A tiny HTTP listener that spawns apps in the real niri session and
  # runs niri IPC actions, for Companion buttons to hit. Companion runs
  # on crate-server, not this host, so it has no access to the host's
  # Wayland session -- this bridges that gap over the LAN: Companion does
  # an HTTP Request action, this listener runs the actual command on the
  # host, same way niri's own spawn-at-startup entries launch apps.
  #
  # /spawn/<name> is allowlist only, by design: this listens on the LAN
  # (reachable from Companion and anything else on the network), so it
  # deliberately maps a fixed set of names to fixed commands rather than
  # accepting an arbitrary command to run.
  #
  # /niri/<action>/<arg>/... is deliberately NOT allowlisted: it passes
  # straight through to `niri msg action <action> <arg>...` so new
  # Companion buttons (workspace switching, window focus, etc.) don't
  # need a redeploy here. Still safe from command injection -- args are
  # exec'd as an argv list, never a shell -- but anything on the LAN can
  # invoke any niri action on this host, e.g. closing windows.
  flake.modules.homeManager.app-spawn-listener = {pkgs, ...}: let
    port = 9797;

    apps = {
      zen = ["zen-beta"];
    };

    listener = pkgs.writers.writePython3Bin "app-spawn-listener" {flakeIgnore = ["E231"];} ''
      import http.server
      import os
      import re
      import subprocess

      APPS = ${builtins.toJSON apps}
      NIRI = "${pkgs.niri}/bin/niri"

      SPAWN_RE = re.compile(r"/spawn/([a-zA-Z0-9_-]+)")
      NIRI_RE = re.compile(r"/niri/([a-zA-Z0-9_-]+)((?:/[a-zA-Z0-9_.:-]+)*)")


      def niri_env():
          env = dict(os.environ)
          env.setdefault(
              "NIRI_SOCKET", f'{env["XDG_RUNTIME_DIR"]}/niri/niri-socket'
          )
          return env


      class Handler(http.server.BaseHTTPRequestHandler):
          def do_GET(self):
              m = SPAWN_RE.fullmatch(self.path)
              if m:
                  name = m.group(1)
                  if name not in APPS:
                      self.send_response(404)
                      self.end_headers()
                      self.wfile.write(b"unknown app\n")
                      return
                  subprocess.Popen(["uwsm", "app", "--", *APPS[name]])
                  self.send_response(200)
                  self.end_headers()
                  self.wfile.write(b"spawned\n")
                  return

              m = NIRI_RE.fullmatch(self.path)
              if m:
                  action = m.group(1)
                  args = [a for a in m.group(2).split("/") if a]
                  cmd = [NIRI, "msg", "action", action, *args]
                  subprocess.Popen(cmd, env=niri_env())
                  self.send_response(200)
                  self.end_headers()
                  self.wfile.write(b"sent\n")
                  return

              self.send_response(404)
              self.end_headers()
              self.wfile.write(b"not found\n")


      if __name__ == "__main__":
          http.server.HTTPServer(("0.0.0.0", ${toString port}), Handler).serve_forever()
    '';
  in {
    home.packages = [listener];

    systemd.user.services.app-spawn-listener = {
      Unit = {
        Description = "HTTP listener that spawns apps and runs niri actions on the host, for Companion buttons";
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
