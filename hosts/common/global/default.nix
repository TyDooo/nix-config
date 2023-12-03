{
  inputs,
  outputs,
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

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";
}
