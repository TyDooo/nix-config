{
  flake.nixosModules.role-headless = {
    imports = [
      ./documentation.nix
      ./fonts.nix
    ];
  };
}
