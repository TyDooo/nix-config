{
  description = "TyDooo's nix config";

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      imports = [
        ./parts

        ./clan.nix

        (inputs.import-tree ./modules/features)

        ./modules/roles/admin
        ./modules/roles/gaming
        ./modules/roles/graphical
        ./modules/roles/headless
        ./modules/roles/server
      ];
    };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    clan-core.url = "https://git.clan.lol/clan/clan-core/archive/main.tar.gz";
    clan-core.inputs.nixpkgs.follows = "nixpkgs";
    clan-core.inputs.flake-parts.follows = "flake-parts";

    clan-community.url = "https://git.clan.lol/clan/clan-community/archive/main.tar.gz";
    clan-community.inputs.clan-core.follows = "clan-core";
    clan-community.inputs.nixpkgs.follows = "nixpkgs";
    clan-community.inputs.treefmt-nix.follows = "treefmt-nix";

    vpn-confinement.url = "github:Maroka-chan/VPN-Confinement";

    treefmt-nix.follows = "clan-core/treefmt-nix";

    nix-index-db.url = "github:nix-community/nix-index-database";
    nix-index-db.inputs.nixpkgs.follows = "nixpkgs";

    copyparty.url = "github:9001/copyparty";

    impermanence.url = "github:nix-community/impermanence";
    impermanence.inputs.nixpkgs.follows = "nixpkgs";
    impermanence.inputs.home-manager.follows = "home-manager";

    # Do not override its nixpkgs input, otherwise there can be mismatch between patches and kernel version
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

    nur.url = "github:nix-community/NUR";
    nur.inputs.nixpkgs.follows = "nixpkgs";
    nur.inputs.flake-parts.follows = "flake-parts";

    noctalia-greeter.url = "github:noctalia-dev/noctalia-greeter";
    noctalia-greeter.inputs.nixpkgs.follows = "nixpkgs";

    import-tree.url = "github:vic/import-tree";

    wrapper-modules.url = "github:BirdeeHub/nix-wrapper-modules";
    wrapper-modules.inputs.nixpkgs.follows = "nixpkgs";
  };
}
