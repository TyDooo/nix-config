{
  grimoire-utils,
  config,
  lib,
  ...
}:
let
  version = "3.0.1";

  redisPort = 6380;
  database = {
    inherit (config.services.postgresql.settings) port;
    name = "audiomuse";
    user = "audiomuse";
  };

  containerConf = {
    image = "ghcr.io/neptunehub/audiomuse-ai:${version}";
    autoStart = true;
    extraOptions = [
      "--network=host"
      "--tmpfs=/app/temp_audio:size=1G,mode=1777"
    ];
    environmentFiles = [ config.clan.core.vars.generators."audiomuse".files."envfile".path ];
  };

  containerEnv = {
    TZ = "Europe/Amsterdam";

    MEDIASERVER_TYPE = "navidrome";
    NAVIDROME_URL = "http://localhost:4533";
    NAVIDROME_USER = "audiomuse";
    # NAVIDROME_PASSWORD: provided through SOPS

    POSTGRES_HOST = "127.0.0.1";
    POSTGRES_PORT = toString database.port;
    POSTGRES_DB = database.name;
    POSTGRES_USER = database.user;

    REDIS_URL = "redis://localhost:${toString redisPort}/0";
    REDIS_PORT = toString redisPort;

    AUTH_ENABLED = "true";
    # AUDIOMUSE_USER: provided through SOPS
    # AUDIOMUSE_PASSWORD: provided through SOPS

    AI_MODEL_PROVIDER = "NONE";
    CLAP_ENABLED = "true";
    CLUSTERING_RUNS = "5000";
    LYRICS_ENABLED = "true";
  };
in
{
  services.redis.servers.audiomuse = {
    enable = true;
    port = redisPort;
    bind = "127.0.0.1";
  };

  clan.core.vars.generators."audiomuse" = grimoire-utils.mkEnvGenerator [
    "NAVIDROME_PASSWORD"
    "AUDIOMUSE_USER"
    "AUDIOMUSE_PASSWORD"
  ];

  services.postgresql = {
    ensureDatabases = [ database.name ];
    ensureUsers = [
      {
        name = database.user;
        ensureDBOwnership = true;
      }
    ];
    # Allow the audiomuse container (connecting via TCP on loopback) to authenticate
    authentication = lib.mkAfter ''
      host ${database.name} ${database.user} 127.0.0.1/32 trust
    '';
  };

  virtualisation.oci-containers.containers = {
    audiomuse-ai = containerConf // {
      environment = containerEnv // {
        SERVICE_TYPE = "flask";
      };
    };

    audiomuse-ai-worker = containerConf // {
      environment = containerEnv // {
        SERVICE_TYPE = "worker";
      };
    };
  };

  systemd.services = {
    podman-audiomuse-ai.serviceConfig = {
      requires = "navidrome.service";
      after = "navidrome.service";
    };
    podman-audiomuse-ai-worker.serviceConfig = {
      requires = "navidrome.service";
      after = "navidrome.service";
    };
  };

  networking.firewall.allowedTCPPorts = [ 8000 ];
}
