{
  config,
  pkgs,
  ...
}: let
  waybar_config = import ./config.nix {inherit config pkgs;};
in {
  programs.waybar = {
    enable = true;
    package = pkgs.waybar.overrideAttrs (oldAttrs: {
      mesonFlags = oldAttrs.mesonFlags ++ ["-Dexperimental=true"];
    });

    settings = waybar_config;
    style = import ./styles.nix;
  };
}
