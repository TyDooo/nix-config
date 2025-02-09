let
  shellAliases = {
    ":q" = "exit";
    "q" = "exit";
    ".." = "cd ..";
  };
in {
  programs = {
    thefuck.enable = true;
    bat.enable = true;
    fd.enable = true;

    eza = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
    };

    ripgrep.enable = true;

    starship = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
    };

    zoxide = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
    };

    yazi = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
    };

    zsh = {
      inherit shellAliases;
      enable = true;
      enableCompletion = true;
      syntaxHighlighting.enable = true;
      autosuggestion.enable = true;
    };

    tmux = {
      enable = true;
      clock24 = true;
      keyMode = "vi";
      mouse = true;
      historyLimit = 5000;
      prefix = "C-s";
      sensibleOnTop = true;
      shell = "\${pkgs.zsh}/bin/zsh";
    };
  };
}
