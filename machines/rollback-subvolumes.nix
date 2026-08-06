# Deletes and recreates @root/@home/@var on every boot before sysroot
# mounts, so nothing survives a reboot except what's declared under
# environment.persistence -- see aspects/tools/impermanence.nix.
rootDevice: {
  boot.initrd.systemd.services.rollback = {
    description = "Rollback BTRFS subvolumes";
    wantedBy = ["initrd.target"];
    after = ["initrd-root-device.target"];
    before = ["sysroot.mount"];
    unitConfig.DefaultDependencies = "no";
    serviceConfig.Type = "oneshot";
    script = ''
      mkdir -p /btrfs_tmp
      mount -o subvol=/ ${rootDevice} /btrfs_tmp

      delete_subvolume_recursively() {
        IFS=$'\n'
        for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
          delete_subvolume_recursively "/btrfs_tmp/$i"
        done
        btrfs subvolume delete "$1"
      }

      [[ -e /btrfs_tmp/@root ]] && delete_subvolume_recursively /btrfs_tmp/@root
      [[ -e /btrfs_tmp/@home ]] && delete_subvolume_recursively /btrfs_tmp/@home
      [[ -e /btrfs_tmp/@var ]] && delete_subvolume_recursively /btrfs_tmp/@var

      btrfs subvolume create /btrfs_tmp/@root
      btrfs subvolume create /btrfs_tmp/@home
      btrfs subvolume create /btrfs_tmp/@var
      umount /btrfs_tmp
    '';
  };
}
