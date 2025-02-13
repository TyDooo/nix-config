{
  perSystem = {pkgs, ...}: {
    devShells.default = pkgs.mkShell {
      packages = with pkgs; [
        alejandra
        nil
        deadnix

        git # Required to use flakes
      ];
    };
  };
}
