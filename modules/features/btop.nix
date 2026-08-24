{ inputs, ... }: {
  perSystem =
    { pkgs, ... }:
    let
      rose-pine-theme = pkgs.fetchFromGitHub {
        owner = "rose-pine";
        repo = "btop";
        rev = "c27e5d48e44e8bd115a2838ecf8cf1f3ea39475e";
        hash = "sha256-vtqqMEQbPOSRfQ28RIln5zZ4cZlyB3sMc2NaLUcITWo=";
      };
    in
    {
      packages.btop-wrapped = inputs.wrapper-modules.wrappers.btop.wrap {
        inherit pkgs;

        settings = {
          color_theme = "rose-pine";
        };

        themes = {
          rose-pine = builtins.readFile "${rose-pine-theme}/rose-pine.theme";
        };
      };
    };
}
