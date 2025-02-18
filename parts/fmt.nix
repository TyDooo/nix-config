{inputs, ...}: {
  imports = [inputs.treefmt-nix.flakeModule];
  perSystem = {
    config,
    pkgs,
    ...
  }: {
    # Use treefmt as the formatter package for `nix fmt`.
    formatter = config.treefmt.build.wrapper;

    treefmt = {
      projectRootFile = "flake.nix";
      enableDefaultExcludes = true;

      settings = {
        global.excludes = [".envrc"];
      };

      programs = {
        deadnix.enable = true;
        statix.enable = true;
        alejandra.enable = true;
        prettier = {
          enable = true;
          package = pkgs.prettierd;
        };
      };
    };
  };
}
