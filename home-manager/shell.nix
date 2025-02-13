{pkgs, ...}: let
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
    eza.enable = true;
    fzf.enable = true;
    ripgrep.enable = true;
    starship.enable = true;

    zoxide = {
      enable = true;
      options = ["--cmd cd"]; # Replace the cd command
    };

    yazi = {
      enable = true;
      enableZshIntegration = true;
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
      shell = "${pkgs.zsh}/bin/zsh";
      plugins = with pkgs.tmuxPlugins; [
        vim-tmux-navigator
        {
          plugin = tokyo-night-tmux;
          extraConfig = ''
            set -g @plugin "janoamaral/tokyo-night-tmux"
            set -g @tokyo-night-tmux_theme night
            set -g @tokyo-night-tmux_transparent 1
          '';
        }
      ];
    };
  };
}
