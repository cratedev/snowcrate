{...}: {
  # Bitfocus Companion: a self-hosted Stream Deck-style button grid,
  # controlled from any browser on the LAN -- used from an old Android
  # phone instead of dedicated hardware. Admin/control UI on :8000;
  # 16622/16623 are for Companion Satellite (unused for now, but cheap
  # to expose in case physical surfaces get added later).
  flake.modules.nixos.companion = {...}: {
    virtualisation.oci-containers.backend = "docker";

    virtualisation.oci-containers.containers.companion = {
      image = "bitfocus/companion:latest";
      autoStart = true;
      ports = [
        "8000:8000"
        "16622:16622"
        "16623:16623"
      ];
      volumes = ["/var/lib/companion:/companion"];
    };

    # Same class of bug hit with unraid-compose: at boot, the image pull
    # can race ahead of DNS actually being usable. On this host DNS is
    # resolved entirely through Tailscale's MagicDNS (100.100.100.100,
    # per /etc/resolv.conf) -- network-online.target alone doesn't
    # guarantee tailscaled has finished reconnecting yet, so wait for it
    # explicitly too. The default restart spacing is also too tight to
    # survive more than a couple of quick failures before hitting
    # systemd's start-limit.
    systemd.services.docker-companion = {
      after = ["network-online.target" "tailscaled.service"];
      wants = ["network-online.target" "tailscaled.service"];
      serviceConfig.RestartSec = "20s";
      startLimitIntervalSec = 600;
      startLimitBurst = 6;
    };

    environment.persistence."/persist".directories = ["/var/lib/companion"];
  };
}
