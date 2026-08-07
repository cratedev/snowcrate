{...}: {
  flake.modules.nixos.android-studio = {pkgs, ...}: {
    # Lets nix build Android SDK components directly (androidenv), not just
    # whatever Android Studio's own SDK Manager downloads at runtime.
    nixpkgs.config.android_sdk.accept_license = true;

    # Gradle pulls aapt2 (and other AGP build tools) as prebuilt dynamically
    # linked binaries via Maven -- they expect a standard FHS dynamic linker
    # that doesn't exist on NixOS and fail with "cannot execute binary
    # file" / "error while loading shared libraries" otherwise.
    programs.nix-ld = {
      enable = true;
      libraries = with pkgs; [
        stdenv.cc.cc
        zlib
      ];
    };

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
