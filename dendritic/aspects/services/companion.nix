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

    environment.persistence."/persist".directories = ["/var/lib/companion"];
  };
}
