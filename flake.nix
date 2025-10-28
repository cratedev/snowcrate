{
  inputs = {
    mysecrets = {
      url = "git+ssh://git@github.com/cratedev/nix-secrets";
      flake = false;
    };
    disko.url = "github:nix-community/disko";
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
    niri.url = "github:sodiboo/niri-flake"; #?rev=d68e48d09510bc7b0724e25da8eab868189c7084";
    hyprland.url = "github:hyprwm/Hyprland";
    determinate.url = "github:DeterminateSystems/determinate";
    agenix.url = "github:ryantm/agenix";
    ghostty.url = "github:ghostty-org/ghostty";
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    impermanence.url = "github:nix-community/impermanence";
    nvf.url = "github:notashelf/nvf";
    caelestia-shell = {
      url = "github:caelestia-dots/shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dgop = {
      url = "github:AvengeMedia/dgop";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dms-cli = {
      url = "github:AvengeMedia/danklinux";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dankMaterialShell = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.dgop.follows = "dgop";
      inputs.dms-cli.follows = "dms-cli";
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
        inputs.determinate.nixosModules.default
        inputs.nix-ssh.nixosModules.ssh
        inputs.disko.nixosModules.disko
        #./secrets/default.nix
      ];

      systems.hosts.crate-laptop.modules = with inputs; [nixos-hardware.nixosModules.dell-xps-15-9510];
    };
}
