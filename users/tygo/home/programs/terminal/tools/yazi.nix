{
  config,
  pkgs,
  ...
}: {
  home.packages = [pkgs.exiftool];

  programs.yazi = {
    enable = true;

    enableBashIntegration = config.programs.bash.enable;
    enableZshIntegration = config.programs.zsh.enable;
  };
}
