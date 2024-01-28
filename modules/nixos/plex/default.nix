{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  cfg = config.tydooo.services.plex;
in {
  options.tydooo.services.plex = {
    enable = mkEnableOption "plex media server";
  };

  config = mkIf cfg.enable {
    services = {
      plex = {
        enable = true;
        group = "media";
        openFirewall = true;
        extraScanners = [
          (pkgs.fetchFromGitHub {
            owner = "ZeroQI";
            repo = "Absolute-Series-Scanner";
            rev = "ddca35eecb2377e727850e0497bc9b1f67fc11e7";
            sha256 = "xMZPSi6+YUNFJjNmiiIBN713A/2PKDuQ1Iwm5c/Qt+s=";
          })
        ];
        extraPlugins = [
          (pkgs.fetchFromGitHub {
            owner = "ZeroQI";
            repo = "Hama.bundle";
            rev = "c6987a00e68b23883a263481c823bb7aa7684c21";
            sha256 = "pH7oO0dsTA2zXsquwCV6z8IdNoDwippP806KT9TX4RU=";
          })
        ];
      };
    };
  };
}
