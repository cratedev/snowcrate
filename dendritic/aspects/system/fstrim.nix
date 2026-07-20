{...}: {
  flake.modules.nixos.fstrim = {...}: {
    # Periodic TRIM for SSDs. No-op on filesystems that don't support
    # discard (e.g. crate-server's spinning-disk array), so safe to
    # enable universally.
    services.fstrim.enable = true;
  };
}
