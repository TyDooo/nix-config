{
  description = "TyDooo's config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    hyprland.url = "github:hyprwm/Hyprland";
    nix-colors.url = "github:misterio77/nix-colors"; # TODO: use this!
    nur.url = "github:nix-community/NUR";

    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    spicetify-nix = {
      url = "github:the-argus/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = inputs@{ self, nixpkgs, nur, home-manager, pre-commit-hooks
    , flake-utils, ... }:
    let
      inherit (self) outputs;
      lib = nixpkgs.lib // home-manager.lib;
      systems = [ "x86_64-linux" ];
      forEachSystem = f: lib.genAttrs systems (system: f pkgsFor.${system});
      pkgsFor = lib.genAttrs systems (system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        });
    in {
      homeManagerModules = import ./modules/home-manager;

      formatter = forEachSystem (pkgs: pkgs.nixpkgs-fmt);

      nixosConfigurations = {
        # Personal desktop
        aerial = lib.nixosSystem {
          modules = [ ./hosts/aerial ];
          specialArgs = { inherit inputs outputs; };
        };
        # External server (Hetzner)
        balthasar = lib.nixosSystem {
          modules = [ ./hosts/balthasar ];
          specialArgs = { inherit inputs outputs; };
        };
      };

      homeConfigurations = {
        "tygo@aerial" = lib.homeManagerConfiguration {
          modules = [ ./home/aerial.nix ];
          pkgs = pkgsFor.x86_64-linux;
          extraSpecialArgs = { inherit inputs outputs nur; };
        };
        "tygo@balthasar" = lib.homeManagerConfiguration {
          modules = [ ./home/balthasar.nix ];
          pkgs = pkgsFor.x86_64-linux;
          extraSpecialArgs = { inherit inputs outputs; };
        };
      };
    }

    # Enable commit hooks for nix config repo
    // flake-utils.lib.eachDefaultSystem (system: {
      checks.pre-commit-check = pre-commit-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
          nixfmt.enable = true;
          deadnix.enable = true;
          statix.enable = true;
        };
        settings = {
          deadnix.edit = true;
          deadnix.noLambdaArg = true;
        };
      };
      devShell = nixpkgs.legacyPackages.${system}.mkShell {
        inherit (self.checks.${system}.pre-commit-check) shellHook;
      };
    });
}
