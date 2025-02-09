{
  programs.git = {
    enable = true;
    userName = "Tygo Driessen";
    userEmail = "tygo@driessen.family";
    aliases = {
      st = "status";
    };
    ignores = [
      ".direnv"
      "result"
    ];
  };
}
