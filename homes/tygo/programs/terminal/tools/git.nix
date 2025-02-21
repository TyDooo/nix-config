{pkgs, ...}: {
  programs.git = {
    enable = true;
    package = pkgs.gitFull;

    userName = "Tygo Driessen";
    userEmail = "tygo@driessen.family";

    signing = {
      key = "39EB68CAC6016379";
      signByDefault = true;
    };

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
