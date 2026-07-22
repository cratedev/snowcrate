{...}: {
  # Impactor (iOS/tvOS sideloading tool) has no nixpkgs package and its
  # own flake only exposes a devShell, not an installable output -- so
  # it's installed via Flatpak instead, matching upstream's own
  # supported Linux distribution method.
  flake.modules.nixos.impactor = {pkgs, ...}: {
    services.flatpak.enable = true;
    # Manages the USB multiplexing connection to iOS devices -- Impactor
    # can't see/pair a connected device without it.
    services.usbmuxd.enable = true;

    systemd.services.flatpak-impactor-setup = {
      description = "Ensure the flathub remote and Impactor flatpak are installed";
      wantedBy = ["multi-user.target"];
      after = ["network-online.target"];
      wants = ["network-online.target"];
      serviceConfig.Type = "oneshot";
      path = [pkgs.flatpak];
      script = ''
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        flatpak install -y flathub dev.khcrysalis.PlumeImpactor
      '';
    };

    environment.persistence."/persist".users.matt.directories = [
      ".var/app/dev.khcrysalis.PlumeImpactor"
    ];
  };
}
