{...}: {
  # Previously split across modules/nixos/tools/git and modules/home/tools/git
  # with two independent `enable` options that had to be flipped in sync,
  # and overlapping programs.git config declared in both places.
  flake.modules.nixos.git = {pkgs, ...}: {
    environment.systemPackages = [pkgs.git-crypt];
  };

  flake.modules.homeManager.git = {pkgs, ...}: {
    home.packages = [pkgs.lazygit];

    programs.git = {
      enable = true;
      settings = {
        user.name = "Matthew Henderson";
        user.email = "matt@crate.dev";
        init.defaultBranch = "master";
        pull.rebase = true;
        push.autoSetupRemote = true;
      };
      ignores = ["result"];
      lfs.enable = true;
    };
  };
}
