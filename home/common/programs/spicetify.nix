{
  pkgs,
  inputs,
  ...
}: {
  # themable spotify
  programs.spicetify = let
    spicePkgs =
      inputs.spicetify-nix.packages.${pkgs.system}.default;
  in {
    enable = true;
    injectCss = true;
    replaceColors = true;
    overwriteAssets = true;
    sidebarConfig = true;
    theme = spicePkgs.themes.catppuccin;
    colorScheme = "mocha";
  };
}
