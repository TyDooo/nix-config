let
  shellAliases = {
    ":q" = "exit";
    "q" = "exit";
    ".." = "cd ..";
  };
in {
  programs.zsh = {
    inherit shellAliases;
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;
  };
}
