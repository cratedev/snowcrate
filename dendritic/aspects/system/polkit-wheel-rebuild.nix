{...}: {
  flake.modules.nixos.polkit-wheel-rebuild = {...}: {
    # wheel already has unrestricted root via sudo on every host, so this
    # doesn't grant a new privilege -- it just lets `nixos-rebuild
    # switch/test` (Determinate Nix's systemd-run+polkit activation step)
    # finish non-interactively over SSH, where there's no polkit agent
    # around to answer an interactive auth prompt.
    security.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (
          action.id == "org.freedesktop.systemd1.manage-units" &&
          subject.isInGroup("wheel")
        ) {
          return polkit.Result.YES;
        }
      });
    '';
  };
}
