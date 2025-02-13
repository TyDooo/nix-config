{
  perSystem = {
    config,
    pkgs,
    ...
  }: {
    devShells.default = pkgs.mkShell {
      packages = [
        config.treefmt.build.wrapper

        pkgs.alejandra
        pkgs.nil
        pkgs.deadnix

        pkgs.git # Required to use flakes
      ];
    };
  };
}
