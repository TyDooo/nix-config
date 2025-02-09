{
  description = "Your new nix config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

    # Home manager
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    hyprpanel.url = "github:Jas-SinghFSU/HyprPanel";
    impermanence.url = "github:nix-community/impermanence";
    nvf.url = "github:notashelf/nvf";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nvf,
    ...
  } @ inputs: let
    inherit (self) outputs;

    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};

    customNeovim = nvf.lib.neovimConfiguration {
      inherit pkgs;
      modules = [./nvim.nix];
    };
  in {
    # This will make the package available as a flake output under 'packages'
    packages.${system}.nvim = customNeovim.neovim;

    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = {
      aerial = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        # > Our main nixos configuration file <
        modules = [
          ./nixos/configuration.nix
          {
            nixpkgs.overlays = [inputs.hyprpanel.overlay];
            environment.systemPackages = [customNeovim.neovim]; # TODO: move to configuration.nix
          }
        ];
      };
    };

    # Standalone home-manager configuration entrypoint
    # Available through 'home-manager --flake .#your-username@your-hostname'
    homeConfigurations = {
      "tygo@aerial" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs; # Home-manager requires 'pkgs' instance
        extraSpecialArgs = {inherit inputs outputs;};
        # > Our main home-manager configuration file <
        modules = [./home-manager/home.nix];
      };
    };
  };
}
