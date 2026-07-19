{self, ...}: {
  flake.modules.nixos.role-graphical = {
    imports = with self.modules.nixos; [
      niri
      dms-shell
      dms-greeter

      onepassword

      discord
      obsidian
      ytmusic
      zen

      audio

      cliphist
      fonts
      gvfs
      portals
      wlclipboard
    ];
  };

  flake.modules.homeManager.role-graphical = {
    imports = with self.modules.homeManager; [
      niri
      xdg

      discord
      ghostty
      nautilus
      obsidian
      zen

      mpv
      ytmusic

      dotfile-state
    ];
  };
}
