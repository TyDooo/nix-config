{ inputs, ... }: {
  perSystem = { pkgs, ... }: {
    packages.mpv-wrapped = inputs.wrapper-modules.wrappers.mpv.wrap {
      inherit pkgs;

      script = {
        mpris.path = pkgs.mpvScripts.mpris;
        autoload.path = pkgs.mpvScripts.builtins.autoload;
        thumbfast.path = pkgs.mpvScripts.thumbfast;
        modernz.path = pkgs.mpvScripts.modernz;
      };
    };
  };
}
