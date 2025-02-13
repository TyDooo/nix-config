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
        {
          nixpkgs.overlays = [inputs.hyprpanel.overlay];
        }
      ];
    };
  };
}
