{ pkgs, ... }:

{
  imports = [ ./nix.nix ./fonts.nix ./locale.nix ];

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [ wget vim git home-manager ];
}
