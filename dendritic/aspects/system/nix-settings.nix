{...}: {
  flake.modules.nixos.nix-settings = {pkgs, ...}: {
    environment.systemPackages = [pkgs.nix-prefetch-scripts];

    nix = {
      settings = {
        experimental-features = "nix-command flakes";
        http-connections = 50;
        connect-timeout = 5;
        warn-dirty = false;
        log-lines = 50;
        max-jobs = "auto";
        max-substitution-jobs = "128";
        cores = 0;
        keep-outputs = true;
        builders-use-substitutes = true;
        # matt already has unrestricted root via wheel/sudo on every host;
        # this just lets --build-host copy-back skip a signature check
        # that was never a real trust boundary for this single-user setup.
        trusted-users = ["root" "matt"];
        substituters = [
          # crate-desktop pushes every build here (see
          # aspects/tools/cachix-push.nix) so other hosts -- and
          # crate-desktop itself, on a later rebuild -- can pull
          # already-built store paths instead of rebuilding them.
          "https://snowcrate.cachix.org"
          "https://notashelf.cachix.org"
          "https://cache.nixos.org/"
          "https://nix-community.cachix.org"
          "https://niri-nix.cachix.org"
        ];
        trusted-public-keys = [
          "snowcrate.cachix.org-1:RtoR3YosucK7T5NO9i47k5D3Hce0do5WCST0VMxl+bw="
          "notashelf.cachix.org-1:VTTBFNQWbfyLuRzgm2VHAW2aH7iuDQfFh1OqFn5shZc="
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "niri-nix.cachix.org-1:SvFtqpDcf7Sm1SMJdby1/+Y+6f3Yt3/3PMcSTKPJNJ0="
        ];
      };

      gc = {
        automatic = false;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };

      optimise = {
        automatic = true;
        dates = ["weekly"];
      };
    };
  };
}
