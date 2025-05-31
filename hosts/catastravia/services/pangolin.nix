{
  config,
  utils,
  self',
  pkgs,
  ...
}: let
  dataDir = "/var/lib/fossorial";

  domainName = "driessen.family";
  baseEndpoint = "pangolin.${domainName}";
  dashboardUrl = "https://${baseEndpoint}";

  portExternal = 3000;
  portInternal = 3001;
  portNext = 3002;
  portGerbil = 3003;

  host = "localhost";

  configFormat = pkgs.formats.yaml {};
  pangolinConfig = {
    app = {
      dashboard_url = dashboardUrl;
      log_level = "info";
      save_logs = false;
    };
    domains = {
      domain1 = {
        base_domain = domainName;
        cert_resolver = "letsencrypt";
        prefer_wildcard_cert = true;
      };
    };
    server = {
      external_port = portExternal;
      internal_port = portInternal;
      next_port = portNext;
      internal_hostname = host;
      session_cookie_name = "p_session_token";
      resource_access_token_param = "p_token";
      resource_session_request_param = "p_session_request";
      cors = {
        origins = [dashboardUrl];
        methods = ["GET" "POST" "PUT" "DELETE" "PATCH"];
        headers = ["X-CSRF-Token" "Content-Type"];
        credentials = false;
      };
      resource_access_token_headers = {
        id = "P-Access-Token-Id";
        token = "P-Access-Token";
      };
    };
    traefik = {
      cert_resolver = "letsencrypt";
      http_entrypoint = "web";
      https_entrypoint = "websecure";
    };
    users.server_admin = {
      # The email and password are provided through environment variables
    };
    gerbil = {
      start_port = 51820;
      base_endpoint = baseEndpoint;
      use_subdomain = false;
      block_size = 24;
      site_block_size = 30;
      subnet_group = "100.89.137.0/20";
    };
    rate_limits = {
      global = {
        window_minutes = 1;
        max_requests = 100;
      };
    };
    flags = {
      require_email_verification = false;
      disable_signup_without_invite = true;
      disable_user_create_org = false;
      allow_raw_resources = true;
      allow_base_domain_resources = true;
    };
  };
in {
  networking.firewall = {
    allowedTCPPorts = [80 443]; # Traefik
    allowedUDPPorts = [51820]; # Wireguard
  };

  systemd.tmpfiles.settings.fossorialDirs = {
    "${dataDir}"."d" = {
      mode = "700";
      user = "fossorial";
      group = "fossorial";
    };
    "${dataDir}/config"."d" = {
      mode = "700";
      user = "fossorial";
      group = "fossorial";
    };
  };

  systemd.services = {
    pangolin = {
      description = "Pangolin Service";
      after = ["network.target"];
      wantedBy = ["multi-user.target"];
      before = ["traefik.service"];
      requiredBy = ["traefik.service"];

      preStart = ''
        ln -sf ${configFormat.generate "config.yml" pangolinConfig} config/config.yml
      '';

      serviceConfig = {
        User = "fossorial";
        Group = "fossorial";
        WorkingDirectory = dataDir;
        EnvironmentFile = config.sops.templates."pangolin.env".path;
        Restart = "always";

        BindPaths = [
          "${self'.packages.pangolin}/.next:${dataDir}/.next"
          "${self'.packages.pangolin}/public:${dataDir}/public"
          "${self'.packages.pangolin}/dist:${dataDir}/dist"
          "${self'.packages.pangolin}/node_modules:${dataDir}/node_modules"
        ];

        ExecStartPre = utils.escapeSystemdExecArgs [
          "${self'.packages.pangolin}/bin/pangolin-migrate"
        ];
        ExecStart = utils.escapeSystemdExecArgs [
          "${self'.packages.pangolin}/bin/pangolin"
        ];
      };
    };

    gerbil = {
      description = "Gerbil Service";
      after = [
        "network.target"
        "pangolin.service"
      ];
      wantedBy = ["multi-user.target"];
      requires = ["pangolin.service"];
      before = ["traefik.service"];
      requiredBy = ["traefik.service"];
      serviceConfig = {
        User = "fossorial";
        Group = "fossorial";
        WorkingDirectory = dataDir;
        Restart = "always";
        AmbientCapabilities = ["CAP_NET_ADMIN" "CAP_SYS_MODULE"];
        CapabilityBoundingSet = ["CAP_NET_ADMIN" "CAP_SYS_MODULE"];

        ExecStart = utils.escapeSystemdExecArgs [
          "${self'.packages.gerbil}/bin/gerbil"
          "--reachableAt=http://${host}:${builtins.toString portGerbil}"
          "--generateAndSaveKeyTo=${dataDir}/config/key"
          "--remoteConfig=http://${host}:${builtins.toString portInternal}/api/v1/gerbil/get-config"
          "--reportBandwidthTo=http://${host}:${builtins.toString portInternal}/api/v1/gerbil/receive-bandwidth"
          "--interface=gerbil-wg0"
        ];
      };
    };
  };

  services.traefik = {
    enable = true;
    environmentFiles = [config.sops.templates."traefik.env".path];
    staticConfigOptions = {
      accessLog = {
        bufferingSize = 100;
        fields = {
          defaultMode = "drop";
          headers = {
            defaultMode = "drop";
            names = {
              Authorization = "redact";
              Content-Type = "keep";
              Cookie = "redact";
              User-Agent = "keep";
              X-Forwarded-For = "keep";
              X-Forwarded-Proto = "keep";
              X-Real-Ip = "keep";
            };
          };
          names = {
            ClientAddr = "keep";
            ClientHost = "keep";
            DownstreamContentSize = "keep";
            DownstreamStatus = "keep";
            Duration = "keep";
            RequestMethod = "keep";
            RequestPath = "keep";
            RequestProtocol = "keep";
            RetryAttempts = "keep";
            ServiceName = "keep";
            StartUTC = "keep";
            TLSCipher = "keep";
            TLSVersion = "keep";
          };
        };
        filePath = "${config.services.traefik.dataDir}/logs/access.log";
        filters = {
          minDuration = "100ms";
          retryAttempts = true;
          statusCodes = ["200-299" "400-499" "500-599"];
        };
        format = "json";
      };
      api = {
        dashboard = true;
        insecure = true;
      };
      certificatesResolvers = {
        letsencrypt = {
          acme = {
            caServer = "https://acme-v02.api.letsencrypt.org/directory";
            email = "acme@tygo.driessen.family";
            dnsChallenge = {provider = "cloudflare";};
            storage = "${config.services.traefik.dataDir}/acme.json";
          };
        };
      };
      entryPoints = {
        web.address = ":80";
        websecure = {
          address = ":443";
          http.tls.certResolver = "letsencrypt";
          transport.respondingTimeouts.readTimeout = "30m";
        };
      };
      experimental = {
        plugins = {
          badger = {
            moduleName = "github.com/fosrl/badger";
            version = "v1.1.0";
          };
        };
      };
      log = {
        format = "json";
        level = "INFO";
      };
      providers = {
        http = {
          endpoint = "http://${host}:${builtins.toString portInternal}/api/v1/traefik-config";
          pollInterval = "5s";
        };
        # The dynamic config is automatically added by the nix module
      };
      serversTransport.insecureSkipVerify = true;
    };
    dynamicConfigOptions = {
      http = {
        middlewares = {
          default-whitelist.ipWhiteList.sourceRange = ["10.0.0.0/8" "192.168.0.0/16" "172.16.0.0/12"];
          redirect-to-https.redirectScheme.scheme = "https";
          security-headers = {
            headers = {
              contentTypeNosniff = true;
              customFrameOptionsValue = "SAMEORIGIN";
              customResponseHeaders = {
                Server = "";
                X-Forwarded-Proto = "https";
                X-Powered-By = "";
              };
              forceSTSHeader = true;
              hostsProxyHeaders = ["X-Forwarded-Host"];
              referrerPolicy = "strict-origin-when-cross-origin";
              sslProxyHeaders.X-Forwarded-Proto = "https";
              stsIncludeSubdomains = true;
              stsPreload = true;
              stsSeconds = 63072000;
            };
          };
        };
        routers = {
          api-router = {
            entryPoints = ["websecure"];
            middlewares = ["security-headers"];
            rule = "Host(`${baseEndpoint}`) && PathPrefix(`/api/v1`)";
            service = "api-service";
            tls.certResolver = "letsencrypt";
          };
          main-app-router-redirect = {
            entryPoints = ["web"];
            middlewares = ["redirect-to-https"];
            rule = "Host(`${baseEndpoint}`)";
            service = "next-service";
          };
          next-router = {
            entryPoints = ["websecure"];
            middlewares = ["security-headers"];
            rule = "Host(`${baseEndpoint}`) && !PathPrefix(`/api/v1`)";
            service = "next-service";
            tls = {
              certResolver = "letsencrypt";
              domains = [
                {
                  main = domainName;
                  sans = ["*.${domainName}"];
                }
              ];
            };
          };
          ws-router = {
            entryPoints = ["websecure"];
            middlewares = ["security-headers"];
            rule = "Host(`${baseEndpoint}`)";
            service = "api-service";
            tls.certResolver = "letsencrypt";
          };
        };
        services = {
          api-service.loadBalancer.servers = [{url = "http://${host}:${builtins.toString portExternal}";}];
          next-service.loadBalancer.servers = [{url = "http://${host}:${builtins.toString portNext}";}];
        };
      };
    };
  };

  # https://github.com/NixOS/nixpkgs/issues/265496
  systemd.services.traefik.serviceConfig.WorkingDirectory = "/var/lib/traefik";

  sops.secrets = {
    cloudflare_api_key = {};
    "pangolin/secret" = {};
    "pangolin/admin/email" = {};
    "pangolin/admin/password" = {};
  };

  sops.templates = {
    "traefik.env".content = ''
      CLOUDFLARE_DNS_API_TOKEN=${config.sops.placeholder.cloudflare_api_key}
    '';

    "pangolin.env".content = ''
      SERVER_SECRET=${config.sops.placeholder."pangolin/secret"}
      USERS_SERVERADMIN_EMAIL=${config.sops.placeholder."pangolin/admin/email"}
      USERS_SERVERADMIN_PASSWORD=${config.sops.placeholder."pangolin/admin/password"}
    '';
  };

  users.users.fossorial = {
    name = "fossorial";
    group = "fossorial";
    isSystemUser = true;
  };
  users.groups.fossorial = {};
}
