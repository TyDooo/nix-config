{inputs, ...}: {
  perSystem = {pkgs, ...}: let
    customNeovim = inputs.nvf.lib.neovimConfiguration {
      inherit pkgs;
      modules = [./nvim.nix];
    };
  in {
    packages.nvim = customNeovim.neovim;
  };
}
