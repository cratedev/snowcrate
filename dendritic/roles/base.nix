{self, ...}: {
  flake.modules.nixos.role-base = {
    nixpkgs.config.allowUnfree = true;

    imports = with self.modules.nixos; [
      user
      niri
      dms-shell
      dms-greeter
      git
      onepassword
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
    ];
  };

  flake.modules.homeManager.role-base = {
    imports = with self.modules.homeManager; [
      user
      niri
      git
      xdg
      env
      obsidian
      ghostty
      nautilus
      zen
      discord
      carapace
      btop
      fzf
      just
      nix-index
      starship
      zoxide
      zellij
      ytmusic
      mpv
      nvf
      fish
    ];
  };
}
