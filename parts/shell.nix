{
  perSystem = {
    inputs',
    config,
    self',
    pkgs,
    ...
  }: {
    devShells.default = pkgs.mkShell {
      packages = [
        config.treefmt.build.wrapper

        inputs'.deploy-rs.packages.default

        self'.packages.nvim

        pkgs.alejandra
        pkgs.nil
        pkgs.deadnix
        pkgs.nixos-anywhere

        pkgs.git # Required to use flakes

        # SOPS related stuff
        pkgs.sops
        pkgs.ssh-to-age
        pkgs.gnupg
        pkgs.age
      ];
    };
  };
}
