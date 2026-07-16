{...}: {
  flake.modules.nixos.fish = {...}: {
    environment.persistence."/persist".users.matt.directories = [
      ".local/share/fish"
      ".config/fish"
    ];
  };

  flake.modules.homeManager.fish = {...}: {
    programs.fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting # Disable greeting
      '';
      functions = {
        ntest = "cd $NH_FLAKE && just test";
        nswitch = "cd $NH_FLAKE && just switch";
        ts = "sudo tailscale up --accept-routes";
      };
    };
  };
}
