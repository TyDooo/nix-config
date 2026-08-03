{
  grimoire-utils,
  config,
  pkgs,
  ...
}:
{
  services.caddy = {
    enable = true;
    package = pkgs.caddy.withPlugins {
      plugins = [
        "github.com/caddy-dns/cloudflare@v0.2.4"
      ];
      hash = "sha256-7GoH8YLCoPmPExQxoga2FHB58zQDoZVf1BBwkVi0SsQ=";
    };
    openFirewall = true;
    environmentFile = config.clan.core.vars.generators."caddy".files."envfile".path;

    # TODO: configure caddy-security.
    #  Do I want to use a single identity provider for all caddy applications and multiple authorization policies
    #  or multiple identity provider (meaning OIDC clients in pocket id) instead like here:
    #  https://msfjarvis.dev/posts/setting-up-forward-auth-with-caddy-and-pocket-id/

    virtualHosts = {
      "*.driessen.family".extraConfig = ''
        tls {
          dns cloudflare {env.CLOUDFLARE_TOKEN}
          resolvers 9.9.9.9 149.112.112.112
        }
      '';

      "*.home.driessen.family".extraConfig = ''
        tls {
          dns cloudflare {env.CLOUDFLARE_TOKEN}
          resolvers 9.9.9.9 149.112.112.112
        }
      '';

      "jellyfin.driessen.family".extraConfig = ''
        reverse_proxy http://localhost:8096 {
          header_up X-Real-IP {remote_host}
        }
      '';

      "immich.driessen.family".extraConfig = ''
        reverse_proxy http://localhost:2283 {
          header_up X-Real-IP {remote_host}
        }
      '';

      "navidrome.driessen.family".extraConfig = ''
        reverse_proxy http://localhost:4533 {
          header_up X-Real-IP {remote_host}
        }
      '';

      "overseerr.driessen.family".extraConfig = ''
        redir https://seerr.driessen.family
      '';

      "seerr.driessen.family".extraConfig = ''
        reverse_proxy http://localhost:5055
      '';

      "plex.driessen.family".extraConfig = ''
        reverse_proxy http://localhost:32400 {
          header_up X-Real-IP {remote_host}
        }
      '';

      "homey.driessen.family".extraConfig = ''
        reverse_proxy http://10.10.20.169:4859 {
          header_up X-Real-IP {remote_host}
        }
      '';

      "shoko.home.driessen.family".extraConfig = ''
        reverse_proxy http://localhost:8111
      '';
    };
  };

  clan.core.vars.generators."caddy" = grimoire-utils.mkEnvGenerator [
    "CLOUDFLARE_TOKEN"
  ];

  environment.persistence = {
    "/persist".directories = [
      {
        directory = config.services.caddy.dataDir;
        inherit (config.services.caddy) user group;
        mode = "0770";
      }
    ];
  };
}
