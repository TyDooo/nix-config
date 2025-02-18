{
  programs.git = {
    enable = true;
    userName = "Tygo Driessen";
    userEmail = "tygo@driessen.family";
    aliases = {
      st = "status";
    };
    extraConfig = {
      init.defaultBranch = "main";
    };
    ignores = [
      ".direnv"
      "result"
    ];
  };
}
