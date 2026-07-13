{...}: {
  flake.modules.nixos.onepassword = {...}: {
    programs._1password.enable = true;
    programs._1password-gui = {
      enable = true;
      polkitPolicyOwners = ["matt"];
    };

    environment.etc."1password/custom_allowed_browsers" = {
      text = ''
        .zen-wrapped
        .zen-beta-wrapp
        zen
        zen-beta
      '';
      mode = "0755";
    };
  };
}
