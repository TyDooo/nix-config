{
  services.navidrome = {
    enable = true;
    openFirewall = true;
    settings = {
      Address = "0.0.0.0";
      MusicFolder = "/mnt/storage/data/media/music";
      EnableStarRating = false;
      ScanSchedule = "@every 1h";
    };
  };
}
