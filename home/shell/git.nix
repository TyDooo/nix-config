{pkgs, ...}: {
  home.packages = with pkgs; [gitflow gitAndTools.gitui];

  programs.git = {
    enable = true;
    userName = "TyDooo";
    userEmail = "tydooo@fastmail.com";
    aliases = {
      st = "status";
      br = "branch";
    };
  };
}
