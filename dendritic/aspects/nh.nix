{...}: {
  flake.modules.nixos.nh = {pkgs, ...}: {
    environment.systemPackages = [pkgs.nh];
    programs.nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 4d --keep 3";
    };
  };
}
