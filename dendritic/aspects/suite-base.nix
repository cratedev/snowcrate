{self, ...}: {
  # Everything every crate-* host gets, regardless of role. Mirrors the old
  # modules/nixos/suites/base -- one file, imported, instead of ~25 separate
  # `crate.X.enable = true;` lines repeated per host.
  flake.modules.nixos.suite-base = {
    imports =
      [self.modules.nixos."1password"]
      ++ (with self.modules.nixos; [
        user
        niri
        dms-shell
        dms-greeter
        git
        systemd-manager
        networking
        audio
        nix-settings
        sudo
        agenix-cli
        pam
        fwupd
        beszel
        busybox
        openssh
        gvfs
        tailscale
        portals
        boot
        locale
        fonts
        time
        impermanence
        cliphist
        nh
        wlclipboard
        ripgrep
      ]);
  };
}
