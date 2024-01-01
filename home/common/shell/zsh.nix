{config, ...}: {
  programs = {
    zsh = {
      enable = true;
      enableAutosuggestions = true;
      syntaxHighlighting.enable = true;
      dotDir = ".config/zsh";
      history = {
        save = 10000;
        size = 10000;
        path = "${config.xdg.dataHome}/zsh/history";
      };

      shellAliases = {
        ssh = "kitten ssh";

        l = "eza -lgF --time-style=long-iso --icons";
        la = "eza -lah --tree";
        ls = "eza -h --git --icons --color=auto --group-directories-first -s extension";
        tree = "eza --tree --icons --tree";

        ".." = "cd ..";
      };
    };
  };
}
