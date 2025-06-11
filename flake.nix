{
  inputs = {
    #   mysecrets = {
    #      url = "git+ssh://git@github.com/cratedev/nix-secrets";
    #      flake = false;
    #    };
    snowfall-lib = {
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-ssh.url = "git+ssh://git@github.com/cratedev/nix-ssh";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    niri.url = "github:sodiboo/niri-flake/daf2e18eb92420e05e06adbf3116899c359d8b15";
    hyprland.url = "github:hyprwm/Hyprland";
    agenix.url = "github:yaxitech/ragenix";
    ghostty.url = "github:ghostty-org/ghostty";
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    impermanence.url = "github:nix-community/impermanence";
    nvf.url = "github:notashelf/nvf";
    grim-hyprland.url = "github:eriedaberrie/grim-hyprland";
    astal = {
      url = "github:aylur/astal";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: let
    lib = inputs.snowfall-lib.mkLib {
      inherit inputs;
      src = ./.;
      snowfall = {
        namespace = "crate";
        meta = {
          name = "crate";
          title = "crate";
        };
      };
    };
  in
    lib.mkFlake {
      channels-config.allowUnfree = true;

      systems.modules.nixos = [
        inputs.home-manager.nixosModules.home-manager
        inputs.stylix.nixosModules.stylix
        inputs.niri.nixosModules.niri
        inputs.impermanence.nixosModules.impermanence
        inputs.nix-ssh.nixosModules.ssh
        #inputs.agenix.nixosModules.default
        #./secrets/default.nix
      ];

      systems.hosts.crate-laptop.modules = with inputs; [nixos-hardware.nixosModules.dell-xps-15-9510];
    };
}
