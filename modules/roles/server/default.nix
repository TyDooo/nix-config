{
  flake.nixosModules.role-server = {
    imports = [
      ./systemd.nix
    ];
  };
}
