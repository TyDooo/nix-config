{
  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  systemd.services.navidrome = {
    after = ["mnt-media.mount"];
    requires = ["mnt-media.mount"];
  };

  users.groups.shared.members = ["jellyfin"];

  environment.persistence = {
    "/persist".directories = ["/var/lib/jellyfin"];
  };
}
