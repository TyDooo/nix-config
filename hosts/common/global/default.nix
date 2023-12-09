{
  inputs,
  outputs,
  lib,
  pkgs,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ./acme.nix
    ./nix.nix
    ./fonts.nix
    ./locale.nix
    ./openssh.nix
    ./podman.nix
    ./sops.nix
    ./tailscale.nix
  ];

  home-manager.extraSpecialArgs = {inherit inputs outputs;};

  nixpkgs = {
    overlays = builtins.attrValues outputs.overlays;
    config.allowUnfree = true;
  };

  environment.systemPackages = with pkgs; [
    vim
  ];

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = lib.mkDefault "23.05"; # Did you read the comment?
}
