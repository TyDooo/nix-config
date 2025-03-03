{
  self,
  inputs,
  ...
}: let
  inherit (self) outputs;
in {
  flake.homeConfigurations = {
    "tygo@aerial" = inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
      extraSpecialArgs = {inherit inputs outputs;};
      modules = [./tygo/aerial.nix];
    };
  };
}
