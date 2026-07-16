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
      zellij

      discord
      obsidian
      ytmusic
      zen

      fish
      nvf
      zoxide

      networking
      audio

      sudo
      agenix-cli
      pam

      beszel
      busybox
      fwupd
      gvfs
      openssh
      portals
      tailscale

      boot
      fonts
      locale
      nix-settings
      time

      cliphist
      impermanence
      nh
      ripgrep
      snowcrate-status
      systemd-manager
      wlclipboard
    ];
  };

  flake.modules.homeManager.role-base = {
    imports = with self.modules.homeManager; [
      user

      niri
      xdg

      git

      discord
      ghostty
      nautilus
      obsidian
      zen

      btop
      carapace
      fish
      fzf
      just
      nix-index
      nvf
      starship
      zellij
      zoxide

      mpv
      ytmusic

      dotfile-state

      env
    ];
  };
}
