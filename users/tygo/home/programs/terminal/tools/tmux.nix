{pkgs, ...}: {
  programs.tmux = {
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
}
