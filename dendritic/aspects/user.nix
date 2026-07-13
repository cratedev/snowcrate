{...}: {
  flake.modules.nixos.user = {pkgs, ...}: {
    programs.fish.enable = true;

    users.users.matt = {
      isNormalUser = true;
      home = "/home/matt";
      group = "users";
      shell = pkgs.fish;
      uid = 1001;
      extraGroups = ["steamcmd" "libvirtd"];
      hashedPassword = "$6$0hEDoOmgboCsWYUO$pvKuFdpVIyJYNeLE.Eqg.eGed5ixdvjgDbkdjcpY93XM4aPNj68lyM1yR//7PXNV4Mzz841QII4DYl2.iHo6z.";
    };
  };

  flake.modules.homeManager.user = {...}: {
    home.username = "matt";
    home.homeDirectory = "/home/matt";
    home.stateVersion = "24.05";
    home.file."images/screenshots/.keep".text = "";
  };
}
