{ inputs, nur, ... }:

{
  imports = [
    ./global.nix

    ./desktop
    ./programs

    inputs.spicetify-nix.homeManagerModule
  ];

  # home-manager nixpkgs config
  nixpkgs.overlays = [ nur.overlay ]; # TODO: (re)move

  monitors = [{
    name = "DP-1";
    width = 3440;
    height = 1440;
    refreshRate = 120;
    primary = true;
  }];
}
