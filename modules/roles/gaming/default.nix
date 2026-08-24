{
  flake.nixosModules.role-gaming = {
    programs.steam = {
      enable = true;
      extest.enable = true;
      remotePlay.openFirewall = true;
    };

    programs.gamescope.enable = true;
  };
}
