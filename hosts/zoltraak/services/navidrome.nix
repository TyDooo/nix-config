{
  services.navidrome = {
    enable = true;
    openFirewall = true;
    settings = {
      Address = "0.0.0.0";
      MusicFolder = "/mnt/music";
      EnableInsightsCollector = false;
      EnableStarRating = false;
      EnableSharing = true;
    };
  };

  systemd.services.navidrome = {
    after = ["mnt-music.mount"];
    requires = ["mnt-music.mount"];
  };

  users.groups.shared.members = ["navidrome"];

  environment.persistence = {
    "/persist".directories = ["/var/lib/navidrome"];
  };
}
