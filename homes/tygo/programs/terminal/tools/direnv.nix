{
  home.sessionVariables = {
    # Tell direnv to shutup
    DIRENV_LOG_FORMAT = "";
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
