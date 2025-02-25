{
  self,
  inputs,
  ...
}: let
  inherit (self) outputs;
in {
  flake.nixosConfigurations = {
    aerial = inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs outputs;};
      modules = [
        ./aerial/configuration.nix
        ./common/global
        {
          nixpkgs.overlays = [inputs.hyprpanel.overlay];
        }
      ];
    };
    zoltraak = inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs outputs;};
      modules = [
        ./zoltraak/configuration.nix
        ./common/global

        inputs.home-manager.nixosModules.home-manager
        inputs.disko.nixosModules.default
        ./zoltraak/disko.nix
      ];
    };
  };
}
