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

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [ wget vim git home-manager ];
}
