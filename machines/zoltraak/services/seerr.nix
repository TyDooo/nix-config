{ config, ... }:
{
  # Until https://github.com/NixOS/nixpkgs/pull/450093 is merged
  virtualisation.oci-containers.containers.seerr = {
    image = "ghcr.io/seerr-team/seerr:latest";
    autoStart = true;
    ports = [ "5055:5055" ];
    volumes = [
      "/var/lib/seerr:/app/config"
    ];
    extraOptions = [
      "--init"
    ];
    environment = {
      LOG_LEVEL = "debug";
      TZ = config.time.timeZone;
    };
  };

  services.caddy.virtualHosts = {
    "overseerr.driessen.family".extraConfig = ''
      redir https://seerr.driessen.family
    '';

    "seerr.driessen.family".extraConfig = ''
      reverse_proxy http://localhost:5055
    '';
  };

  environment.persistence = {
    "/persist".directories = [
      {
        directory = "/var/lib/seerr";
        user = "root";
        group = "root";
        mode = "0750";
      }
    ];
  };

  clan.core.state.seerr = {
    folders = [ "/var/lib/seerr" ];
    preBackupScript = ''
      systemctl stop podman-seerr.service
    '';
    postBackupScript = ''
      systemctl start podman-seerr.service
    '';
  };
}
