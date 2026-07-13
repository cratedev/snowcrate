{
  inputs,
  self,
  ...
}: {
  flake.nixosConfigurations.crate-laptop = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {inherit inputs;};
    modules = [
      inputs.determinate.nixosModules.default
      inputs.disko.nixosModules.disko
      inputs.home-manager.nixosModules.home-manager

      # Host-specific raw config reused as-is from the pre-existing
      # (snowfall-lib) system definition -- unchanged, not duplicated.
      ../../systems/x86_64-linux/crate-laptop/hardware.nix
      ../../systems/x86_64-linux/crate-laptop/disk-config.nix
      ../../systems/x86_64-linux/crate-laptop/agenix.nix

      self.modules.nixos.user
      self.modules.nixos.niri
      self.modules.nixos.dms-shell
      self.modules.nixos.dms-greeter
      self.modules.nixos.git
      self.modules.nixos."1password"
      self.modules.nixos.systemd-manager
      self.modules.nixos.fingerprint
      self.modules.nixos.networking
      self.modules.nixos.audio
      self.modules.nixos.nix-settings
      self.modules.nixos.sudo
      self.modules.nixos.agenix-cli
      self.modules.nixos.pam
      self.modules.nixos.fwupd
      self.modules.nixos.beszel
      self.modules.nixos.busybox
      self.modules.nixos.openssh
      self.modules.nixos.gvfs
      self.modules.nixos.tailscale
      self.modules.nixos.power
      self.modules.nixos.portals
      self.modules.nixos.boot
      self.modules.nixos.locale
      self.modules.nixos.fonts
      self.modules.nixos.time
      self.modules.nixos.impermanence
      self.modules.nixos.cliphist
      self.modules.nixos.nh
      self.modules.nixos.wlclipboard
      self.modules.nixos.ripgrep

      {
        nixpkgs.config.allowUnfree = true;
        nixpkgs.overlays = [
          inputs.niri.overlays.niri
          (import ../../overlays/zellij-plugins {})
        ];

        networking = {
          hostName = "crate-laptop";
          domain = "crate.dev";
          networkmanager.enable = true;
          firewall = {
            enable = false;
            checkReversePath = "loose";
          };
        };

        virtualisation.libvirtd.enable = true;
        hardware.bluetooth.enable = true;
        system.stateVersion = "24.05";

        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = {inherit inputs;};

          users.matt.imports = [
            self.modules.homeManager.user
            self.modules.homeManager.niri
            self.modules.homeManager.git
            self.modules.homeManager.xdg
            self.modules.homeManager.obsidian
            self.modules.homeManager.ghostty
            self.modules.homeManager.nautilus
            self.modules.homeManager.zen
            self.modules.homeManager.discord
            self.modules.homeManager.carapace
            self.modules.homeManager.btop
            self.modules.homeManager.fzf
            self.modules.homeManager.just
            self.modules.homeManager.nix-index
            self.modules.homeManager.starship
            self.modules.homeManager.zoxide
            self.modules.homeManager.zellij
            self.modules.homeManager.ytmusic
            self.modules.homeManager.mpv
            self.modules.homeManager.nvf
            self.modules.homeManager.fish
          ];
        };
      }
    ];
  };
}
