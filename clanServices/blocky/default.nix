# Based on: https://git.clan.lol/eyduh/eyduhverse/src/commit/0fe2873cda45d81d130ebd63c1c7656f3042d880/clanServices/blocky/default.nix
let
  redisUsername = "default";
  redisPasswordCredential = "blocky-redis-password";

  mkRedisAuthGenerator =
    {
      pkgs,
      restartUnits ? [ ],
    }:
    {
      share = true;
      files.password = {
        inherit restartUnits;
      };
      runtimeInputs = [ pkgs.openssl ];
      script = ''
        openssl rand -hex 32 > $out/password
      '';
    };
in
{
  _class = "clan.service";

  manifest.name = "blocky";
  manifest.description = "A network-wide DNS sinkhole";
  manifest.categories = [ "Network" ];
  manifest.readme = ''
    The `default` role configures blocky, which is meant to run on an always-on
    machine that the LAN router/modem points to as its DNS resolver, so the policy
    covers every device on the network.
  '';

  manifest.constraints.roles.cache.maxMachines = 1;

  roles.default = {
    description = "Runs Blocky as DNS resolver/sinkhole.";

    interface =
      { lib, ... }:
      let
        inherit (lib) mkOption types;
      in
      {
        options = {
          listenAddresses = mkOption {
            type = types.listOf types.str;
            default = [ "0.0.0.0" ];
            description = ''
              Addresses Blocky binds its DNS listener to. Use specific LAN IPs to
              avoid clashing with systemd-resolved's 127.0.0.53:53 stub.
            '';
          };
          dnsPort = mkOption {
            type = types.port;
            default = 53;
            description = "DNS listen port.";
          };
          httpPort = mkOption {
            type = types.port;
            default = 4000;
            description = "Blocky HTTP API / metrics port.";
          };
          openFirewall = mkOption {
            type = types.bool;
            default = true;
            description = "Open the DNS port (tcp+udp) in the firewall for LAN clients.";
          };
          upstreams = mkOption {
            type = types.listOf types.str;
            default = [
              "tcp-tls:dns.quad9.net:853"
              "tcp-tls:one.one.one.one:853"
            ];
            description = "Default upstream resolvers for non-clan queries (DoT recommended).";
          };
          bootstrapDns = mkOption {
            type = types.listOf types.str;
            default = [
              "9.9.9.9"
              "1.1.1.1"
            ];
            description = "Plain resolvers used to bootstrap DoT upstream hostnames and blocklist URL hosts.";
          };
          forwardClanDomain = mkOption {
            type = types.bool;
            default = true;
            description = "Conditionally forward the clan domain to the local dm-dns unbound (127.0.0.1:5353).";
          };
          denylists = mkOption {
            type = types.attrsOf (types.listOf types.str);
            default = {
              default = [
                "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/wildcard/pro.txt" # HaGeZi - Multi PRO
                "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/wildcard/tif.txt" # HaGeZi - Threat Intelligence Feeds
                "https://cebeerre.github.io/dnsblocklists/NRD/nrd7_asterisk.txt" # HaGeZi - Newly Registered Domains
              ];
            };
            description = "Blocklist groups → list of source URLs (or inline domains).";
          };
          alwaysBlock = mkOption {
            type = types.listOf types.str;
            default = [
              "default"
            ];
            description = "Blocklist groups blocked at all times for the default client group.";
          };
          allowlists = mkOption {
            type = types.attrsOf (types.listOf types.str);
            default = { };
            description = "Allowlist groups → source URLs/domains (override blocks).";
          };
          redis = mkOption {
            type = types.submodule {
              options = {
                database = mkOption {
                  type = types.int;
                  default = 0;
                  description = "Redis database number used by Blocky.";
                };
                required = mkOption {
                  type = types.bool;
                  default = false;
                  description = "Require Redis to be available before Blocky starts.";
                };
                connectionAttempts = mkOption {
                  type = types.int;
                  default = 10;
                  description = "Maximum Blocky attempts to connect to Redis.";
                };
                connectionCooldown = mkOption {
                  type = types.str;
                  default = "3s";
                  description = "Time between Blocky Redis connection attempts.";
                };
              };
            };
            default = { };
            description = "Blocky Redis client settings used when this instance has a cache role.";
          };
        };
      };

    perInstance =
      {
        settings,
        roles,
        instanceName,
        meta,
        ...
      }:
      {
        nixosModule =
          {
            config,
            lib,
            ...
          }:
          let
            inherit (lib) mkIf concatStringsSep optionalAttrs;
            cacheMachines = roles.cache.machines or { };
            cacheMachineNames = lib.attrNames cacheMachines;
            hasCache = cacheMachineNames != [ ];
            cacheMachine = builtins.head cacheMachineNames;
            cacheSettings = cacheMachines.${cacheMachine}.settings;
            authGenerator = "blocky-redis-${instanceName}";
            passwordFile = config.clan.core.vars.generators.${authGenerator}.files.password.path;
          in
          {
            services.blocky = {
              enable = true;
              # The NixOS module validates the generated config in a build sandbox,
              # where systemd's runtime credential directory does not exist.
              enableConfigCheck = !hasCache;
              settings = {
                ports = {
                  dns = concatStringsSep "," (map (a: "${a}:${toString settings.dnsPort}") settings.listenAddresses);
                  http = "127.0.0.1:${toString settings.httpPort}";
                };

                upstreams.groups.default = settings.upstreams;
                bootstrapDns = map (ip: {
                  upstream = "tcp+udp:${ip}";
                  ips = [ ip ];
                }) settings.bootstrapDns;

                # Clan internal names resolve via the dm-dns unbound service on this host.
                conditional.mapping = optionalAttrs settings.forwardClanDomain {
                  "${meta.domain}" = "127.0.0.1:5353";
                };

                blocking = {
                  inherit (settings) denylists allowlists;
                  clientGroupsBlock.default = settings.alwaysBlock;
                };
              }
              // optionalAttrs hasCache {
                redis = {
                  address = "${cacheMachine}.${meta.domain}:${toString cacheSettings.port}";
                  username = redisUsername;
                  password = "file:/run/credentials/blocky.service/${redisPasswordCredential}";
                  inherit (settings.redis) database;
                  inherit (settings.redis) required;
                  inherit (settings.redis) connectionAttempts;
                  inherit (settings.redis) connectionCooldown;
                };
              };
            };

            networking.firewall = mkIf settings.openFirewall {
              allowedTCPPorts = [ settings.dnsPort ];
              allowedUDPPorts = [ settings.dnsPort ];
            };

            systemd.services.blocky.serviceConfig.LoadCredential = mkIf hasCache [
              "${redisPasswordCredential}:${passwordFile}"
            ];
          };
      };
  };

  roles.cache = {
    description = "Runs a shared Redis cache for Blocky resolvers in this instance.";

    interface =
      { lib, ... }:
      let
        inherit (lib) mkOption types;
      in
      {
        options = {
          listenAddress = mkOption {
            type = types.str;
            default = "0.0.0.0";
            description = "Address Redis binds to for Blocky cache clients.";
          };
          port = mkOption {
            type = types.port;
            default = 6379;
            description = "Redis listen port for the shared Blocky cache.";
          };
          openFirewall = mkOption {
            type = types.bool;
            default = true;
            description = "Open the Redis port in the firewall for Blocky cache clients.";
          };
        };
      };

    perInstance =
      {
        settings,
        instanceName,
        ...
      }:
      {
        nixosModule =
          { config, ... }:
          let
            authGenerator = "blocky-redis-${instanceName}";
          in
          {
            services.redis.servers.blocky = {
              enable = true;
              bind = settings.listenAddress;
              inherit (settings) port;
              inherit (settings) openFirewall;
              requirePassFile = config.clan.core.vars.generators.${authGenerator}.files.password.path;
            };
          };
      };
  };

  perMachine =
    { instances, machine, ... }:
    {
      nixosModule =
        { lib, pkgs, ... }:
        let
          cachedInstances = lib.filterAttrs (
            _instanceName: instance: instance.roles ? cache && instance.roles.cache.machines != { }
          ) instances;

          restartUnitsFor =
            instance:
            [ "blocky.service" ]
            ++ lib.optional (builtins.hasAttr machine.name instance.roles.cache.machines) "redis-blocky.service";
        in
        {
          clan.core.vars.generators = lib.mapAttrs' (
            instanceName: instance:
            lib.nameValuePair "blocky-redis-${instanceName}" (mkRedisAuthGenerator {
              inherit pkgs;
              restartUnits = restartUnitsFor instance;
            })
          ) cachedInstances;
        };
    };
}
