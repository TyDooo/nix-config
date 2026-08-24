{
  flake.nixosModules.role-admin = { pkgs, ... }: {
    imports = [
      ./yubikey.nix
    ];

    environment.systemPackages = with pkgs; [
      age
      age-plugin-tpm
    ];
  };
}
