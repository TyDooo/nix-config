{
  nix = {
    settings = {
      auto-optimise-store = true;
      builders-use-substitutes = true;
      experimental-features = "nix-command flakes";
      warn-dirty = false;

      trusted-users = ["root" "@wheel"];
    };
  };

  nixpkgs.config.allowUnfree = true;
}
