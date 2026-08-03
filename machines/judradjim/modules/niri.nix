{ pkgs, ... }:
let
  # 0WD0's niri fork (wd/vertical-layout branch) - adds two-dimensional
  # layouting so niri works on vertical monitors.
  niriFork = pkgs.niri.overrideAttrs (_oldAttrs: rec {
    version = "unstable-fork-2026-06-19";

    src = pkgs.fetchFromGitHub {
      owner = "0WD0";
      repo = "niri";
      rev = "803cf8e53e11d7d9237dc75e6701fcc8863fc1da";
      hash = "sha256-gvoq9a81pprMRsmREcUJ0X0zTgLm9AVMhkTUoxl4NqE=";
    };

    cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
      inherit src;
      name = "niri-unstable-fork-2026-08-03";
      hash = "sha256-HypBB3PL4nVFMNH2+jEK0+dG9dJ920nHi8GwRoeH/v4=";
    };

    # The fork's Cargo.toml version probably won't match `version` above,
    # so skip the version-string sanity check.
    doInstallCheck = false;
  });
in
{
  programs.niri.enable = true;
  programs.niri.package = niriFork;

  services.gnome.gnome-keyring.enable = true;

  services.udisks2.enable = true; # Removable media.
  services.gvfs.enable = true; # Nautilus mount and trash support.

  environment.systemPackages = with pkgs; [
    noctalia-shell
    brightnessctl

    kitty # Terminal emulator
    loupe # GNOME image viewer
    papers # GNOME document viewer
    nautilus # GNOME file manager

    # Niri deps from their docs
    xwayland-satellite
    xdg-desktop-portal-gtk
    xdg-desktop-portal-gnome
  ];
}
