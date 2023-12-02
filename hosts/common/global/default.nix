{ inputs, outputs, pkgs, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ./nix.nix
    ./fonts.nix
    ./locale.nix
    ./openssh.nix
    ./sops.nix
    ./tailscale.nix
  ];

  home-manager.extraSpecialArgs = { inherit inputs outputs; };

  nixpkgs = {
    overlays = builtins.attrValues outputs.overlays;
    config.allowUnfree = true;
  };

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";
}
