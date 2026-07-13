{...}: {
  flake.modules.homeManager.fish = {...}: {
    programs.fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting # Disable greeting
      '';
      functions = {
        ntest = "cd $NH_FLAKE && just test";
        nswitch = "cd $NH_FLAKE && just switch";
        rtest = "cd $NH_FLAKE && just remotetest";
        rswitch = "cd $NH_FLAKE && just remoteswitch";
        ts = "sudo tailscale up --accept-routes";
      };
    };
  };
}
