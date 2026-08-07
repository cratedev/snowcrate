{...}: {
  flake.modules.nixos.android-studio = {...}: {
    # Lets nix build Android SDK components directly (androidenv), not just
    # whatever Android Studio's own SDK Manager downloads at runtime.
    nixpkgs.config.android_sdk.accept_license = true;

    programs.adb.enable = true;
    users.users.matt.extraGroups = [
      "adbusers"
      # Hardware-accelerated emulator: /dev/kvm is root:kvm 0660, so the
      # emulator falls back to slow software rendering without this.
      "kvm"
    ];

    environment.persistence."/persist".users.matt.directories = [
      ".config/Google"
      ".local/share/Google"
      ".android"
      "Android"
    ];
  };

  flake.modules.homeManager.android-studio = {pkgs, ...}: {
    home.packages = [pkgs.android-studio];
  };
}
