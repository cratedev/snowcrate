{...}: {
  flake.modules.nixos.android-studio = {...}: {
    programs.adb.enable = true;
    users.users.matt.extraGroups = ["adbusers"];

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
