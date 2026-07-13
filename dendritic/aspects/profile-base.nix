{self, ...}: {
  flake.modules.homeManager.profile-base = {
    imports = with self.modules.homeManager; [
      user
      niri
      git
      xdg
      env
      obsidian
      ghostty
      nautilus
      zen
      discord
      carapace
      btop
      fzf
      just
      nix-index
      starship
      zoxide
      zellij
      ytmusic
      mpv
      nvf
      fish
    ];
  };
}
