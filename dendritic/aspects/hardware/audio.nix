{...}: {
  flake.modules.nixos.audio = {pkgs, ...}: {
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    security.rtkit.enable = true;
    environment.systemPackages = [pkgs.pulsemixer pkgs.pavucontrol];

    users.users.matt.extraGroups = ["audio"];
  };
}
