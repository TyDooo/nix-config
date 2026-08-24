{
  perSystem =
    {
      inputs',
      config,
      self',
      pkgs,
      ...
    }:
    {
      devShells.default = pkgs.mkShell {
        packages = [
          config.treefmt.build.wrapper

          inputs'.clan-core.packages.clan-cli

          self'.packages.jj-wrapped
        ]
        ++ (with pkgs; [
          nixfmt
          nixos-anywhere

          just
          just-lsp

          git # Required to use flakes

          # Secrets related stuff
          sops
          ssh-to-age
          gnupg
          age
          git-crypt
        ]);
      };
    };
}
