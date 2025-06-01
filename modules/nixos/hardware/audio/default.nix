{
  config,
  pkgs,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.hardware.audio;
in {
  options.${namespace}.hardware.audio = with types; {
    enable = mkBoolOpt false "Whether or not to enable audio.";
  };

  config = mkIf cfg.enable {
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    hardware.pulseaudio.enable = mkForce false;

    environment.systemPackages = with pkgs;
      [pulsemixer pavucontrol] ++ cfg.extra-packages;

    crate.user.extraGroups = ["audio"];

    #    crate.home.extraOptions = {
    #      systemd.user.services.mpris-proxy = {
    #        Unit.Description = "Mpris proxy";
    #        Unit.After = [ "network.target" "sound.target" ];
    #        Service.ExecStart = "${pkgs.bluez}/bin/mpris-proxy";
    #        Install.WantedBy = [ "default.target" ];
    #      };
    #    };
  };
}
