# Based on: https://git.clan.lol/eyduh/eyduhverse/src/commit/0fe2873cda45d81d130ebd63c1c7656f3042d880/clanServices/blocky/default.nix
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
        };
      };

    perInstance = { settings, meta, ... }: {
      nixosModule =
        { lib, ... }:
        let
          inherit (lib) mkIf concatStringsSep optionalAttrs;
        in
        {
          services.blocky = {
            enable = true;
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
            };
          };

          networking.firewall = mkIf settings.openFirewall {
            allowedTCPPorts = [ settings.dnsPort ];
            allowedUDPPorts = [ settings.dnsPort ];
          };
        };
    };
  };

  roles.cache = {
    # TODO: configure a shared redis cache
  };
}
