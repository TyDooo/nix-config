{
  description = "TyDooo's config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    hyprland.url = "github:hyprwm/Hyprland";
    nix-colors.url = "github:misterio77/nix-colors"; # TODO: use this!

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
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    home-manager,
    pre-commit-hooks,
    ...
  }: let
    inherit (self) outputs;
    lib = nixpkgs.lib // home-manager.lib;
    systems = ["x86_64-linux"];
    forEachSystem = f:
      lib.genAttrs systems (system: f system pkgsFor.${system});
    pkgsFor = lib.genAttrs systems (system:
      import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      });
    addPrecommitCheck = system: {
      pre-commit-check = pre-commit-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
          deadnix.enable = true;
          statix.enable = true;
          alejandra.enable = true;
          nil.enable = true;
          shellcheck.enable = true;
          markdownlint.enable = true;
        };
        settings = {
          alejandra.verbosity = "quiet";
          deadnix = {
            edit = true;
            noLambdaArg = true;
            exclude = ["hardware-configuration.nix"];
          };
          statix.ignore = ["hardware-configuration.nix"];
        };
      };
    };
  in {
    homeManagerModules = import ./modules/home-manager;

    overlays = import ./overlays {inherit inputs;};

    checks = forEachSystem (system: pkgs: addPrecommitCheck system);
    devShells =
      forEachSystem
      (system: pkgs: import ./shell.nix {inherit self system pkgs;});
    formatter = forEachSystem (system: pkgs: pkgs.alejandra);

    nixosConfigurations = {
      # Personal desktop
      aerial = lib.nixosSystem {
        modules = [./hosts/aerial];
        specialArgs = {inherit inputs outputs;};
      };
      # External server (Hetzner)
      balthasar = lib.nixosSystem {
        modules = [./hosts/balthasar];
        specialArgs = {inherit inputs outputs;};
      };
    };

    homeConfigurations = {
      "tygo@aerial" = lib.homeManagerConfiguration {
        modules = [./home/aerial.nix];
        pkgs = pkgsFor.x86_64-linux;
        extraSpecialArgs = {inherit inputs outputs;};
      };
      "tygo@balthasar" = lib.homeManagerConfiguration {
        modules = [./home/balthasar.nix];
        pkgs = pkgsFor.x86_64-linux;
        extraSpecialArgs = {inherit inputs outputs;};
      };
    };
  };
}
