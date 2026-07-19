{self, ...}: {
  flake.modules.nixos.role-graphical = {
    imports = with self.modules.nixos; [
      niri
      dms-shell
      dms-greeter
      noctalia-shell

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
      noctalia-shell
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
