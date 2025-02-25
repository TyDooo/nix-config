{pkgs, ...}: {
  home.packages = [
    # (pkgs.discord.override {
    #   nss = pkgs.nss_latest;
    #   withOpenASAR = true;
    #   withVencord = true;
    # })
    pkgs.discord-canary
  ];
}
