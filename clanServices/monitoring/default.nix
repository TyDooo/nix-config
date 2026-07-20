{ lib, ... }: {
  _class = "clan.service";
  manifest.name = "monitoring";
  manifest.description = "Monitoring stack gathering metrics and logs with a small resource footprint.";
  manifest.readme = builtins.readFile ./README.md;
  manifest.categories = [
    "System"
    "Monitoring"
  ];
  manifest.exports.out = [
    "endpoints"
    "auth"
  ];
  manifest.constraints.roles.server.maxMachines = 1;

  roles.server = {
    description = "Store and visualize metrics and logs.";

    interface =
      { meta, lib, ... }:
      {
        options = {
          grafana = lib.mkOption {
            type = lib.types.submodule {
              options = {
                oidc = lib.mkOption {
                  type = lib.types.submodule {
                    options = {
                      enable = lib.mkEnableOption "OIDC-only authentication.";

                      issuer = lib.mkOption {
                        type = lib.types.str;
                        default = "";
                        example = "https://auth.example.com";
                        description = "Base URL of the OIDC provider (Pocket-ID). Used to derive auth/token/userinfo endpoints.";
                      };

                      clientId = lib.mkOption {
                        type = lib.types.str;
                        default = "grafana";
                        description = "OIDC client ID registered with the provider";
                      };

                      providerName = lib.mkOption {
                        type = lib.types.str;
                        default = "Pocket ID";
                        description = "Display name shown on the Grafana login button";
                      };
                    };
                  };
                };
              };
            };
          };

          host = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = "status.${meta.domain}";
            description = ''
              Hostname or address of the monitoring server (e.g. "qube.email").
              The protocol (http/https) is controlled by the client's useSSL option.
              If null, derived automatically from the server machine name and meta.domain.
            '';
            example = "monitoring.example.com";
          };
        };
      };

    perInstance = { settings, mkExports, ... }: {
      exports = mkExports (
        {
          endpoints.hosts = [ settings.host ];
        }
        // lib.optionalAttrs settings.grafana.oidc.enable {
          auth.client = {
            clientId = settings.grafana.oidc.clientId;
            clientName = "Grafana";
            redirectUris = [ "https://${settings.host}/login/generic_oauth" ];
            scopes = [
              "openid"
              "profile"
              "email"
              "groups"
            ];
            public = false;
          };
        }
      );

      nixosModule =
        {
          config,
          pkgs,
          lib,
          ...
        }:
        let
          oidc = settings.grafana.oidc;
          mimirInstanceAddress = "127.0.0.1";
          networkingInterfaces = builtins.attrNames config.networking.interfaces;
        in
        {
          clan.core = {
            postgresql = {
              enable = true;
              users.grafana = { };
              databases.grafana = {
                create.options = {
                  OWNER = "grafana";
                };
                restore.stopOnRestore = [ "grafana" ];
              };
            };

            state.monitoring.folders = [
              "/var/lib/mimir"
              config.services.loki.dataDir
            ];

            vars.generators."grafana" = {
              files."secret-key".owner = "grafana";
              runtimeInputs = [ pkgs.openssl ];
              script = ''
                openssl rand -hex 32 > "$out/secret-key"
              '';
            };

            vars.generators."monitoring-caddy-auth" = {
              dependencies = [
                "loki-auth"
                "mimir-auth"
              ];
              files."environment".restartUnits = [ "caddy.service" ];
              script = ''
                loki_username="$(cat "$in/loki-auth/username")"
                loki_password_hash="$(cut -d: -f2- "$in/loki-auth/htpasswd")"
                mimir_username="$(cat "$in/mimir-auth/username")"
                mimir_password_hash="$(cut -d: -f2- "$in/mimir-auth/htpasswd")"

                printf 'LOKI_USERNAME=%s\nLOKI_PASSWORD_HASH=%s\n' \
                  "$loki_username" "$loki_password_hash" > "$out/environment"
                printf 'MIMIR_USERNAME=%s\nMIMIR_PASSWORD_HASH=%s\n' \
                  "$mimir_username" "$mimir_password_hash" >> "$out/environment"
              '';
            };
          };

          environment.persistence = {
            "/persist".directories = [
              {
                directory = "/var/lib/private/mimir";
                mode = "0700";
              }
              {
                directory = config.services.loki.dataDir;
                inherit (config.services.loki) user group;
              }
            ];
          };

          services.caddy = {
            enable = true;
            virtualHosts."${settings.host}".extraConfig = ''
              @loki path /loki /loki/*
              handle @loki {
                basic_auth {
                  {$LOKI_USERNAME} {$LOKI_PASSWORD_HASH}
                }
                reverse_proxy 127.0.0.1:${toString config.services.loki.configuration.server.http_listen_port}
              }

              @mimir path /mimir /mimir/*
              handle @mimir {
                basic_auth {
                  {$MIMIR_USERNAME} {$MIMIR_PASSWORD_HASH}
                }
                reverse_proxy 127.0.0.1:${toString config.services.mimir.configuration.server.http_listen_port}
              }

              handle {
                reverse_proxy 127.0.0.1:${toString config.services.grafana.settings.server.http_port}
              }
            '';
          };

          systemd.services.caddy.serviceConfig.EnvironmentFile = [
            config.clan.core.vars.generators."monitoring-caddy-auth".files."environment".path
          ];

          services.mimir = {
            enable = true;
            configuration = {
              server = {
                http_listen_port = 9003;
                http_path_prefix = "/mimir";
              };

              usage_stats.enabled = false;
              multitenancy_enabled = false;

              api.prometheus_http_prefix = "/prometheus";

              memberlist = {
                bind_addr = [ mimirInstanceAddress ];
                advertise_addr = mimirInstanceAddress;
              };

              alertmanager.sharding_ring = {
                replication_factor = 1;
                instance_addr = mimirInstanceAddress;
              };

              compactor.sharding_ring = {
                instance_addr = mimirInstanceAddress;
              };

              distributor.ring = {
                instance_addr = mimirInstanceAddress;
              };

              frontend.address = mimirInstanceAddress;

              ingester.ring = {
                instance_addr = mimirInstanceAddress;
                replication_factor = 1;
              };

              querier.ring = {
                instance_addr = mimirInstanceAddress;
              };

              query_scheduler.ring = {
                instance_addr = mimirInstanceAddress;
              };

              ruler.ring = {
                instance_addr = mimirInstanceAddress;
              };

              store_gateway.sharding_ring = {
                instance_addr = mimirInstanceAddress;
                replication_factor = 1;
              };
            };
          };

          services.loki = {
            enable = true;

            configuration = {
              analytics.reporting_enabled = false;

              auth_enabled = false;

              common = {
                path_prefix = config.services.loki.dataDir;
                replication_factor = 1;
                instance_interface_names = networkingInterfaces;
                ring = {
                  instance_addr = "127.0.0.1";
                  kvstore.store = "inmemory";
                };
              };

              schema_config = {
                configs = [
                  {
                    from = "2026-07-20";
                    object_store = "filesystem";
                    schema = "v13";
                    store = "tsdb";
                    index = {
                      prefix = "index_";
                      period = "24h";
                    };
                  }
                ];
              };

              server = {
                http_listen_port = 9004;
                http_path_prefix = "/loki";
                grpc_listen_port = 9096;
              };

              storage_config.filesystem.directory = "${config.services.loki.dataDir}/chunks";
            };
          };

          # Grafana's OIDC client secret is published by the Pocket ID reconciler at
          # /run/pocket-id-clients/<id>/secret (root:pocket-id-clients 0640). Load it
          # as a systemd credential and wait until the reconciler has written it.
          systemd.services.grafana = lib.mkIf oidc.enable {
            after = [ "pocket-id-clients.service" ];
            requires = [ "pocket-id-clients.service" ];
            serviceConfig.LoadCredential = [
              "oidc-secret:/run/pocket-id-clients/${oidc.clientId}/secret"
            ];
          };

          services.grafana = {
            enable = true;

            settings = {
              server = {
                domain = settings.host;
                root_url = "https://${settings.host}/";
                # Default is 3000
                http_port = 9005;
                http_addr = "127.0.0.1";
              };

              analytics = {
                enabled = false;
                reporting_enabled = false;
                check_for_updates = false;
                check_for_plugin_updates = false;
                feedback_links_enabled = false;
              };

              database = {
                type = "postgres";
                host = "/run/postgresql";
                user = "grafana";
                name = "grafana";
              };

              security.secret_key = "$__file{${
                config.clan.core.vars.generators."grafana".files."secret-key".path
              }}";
            }
            // lib.optionalAttrs oidc.enable {
              # SCIM is enabled by default in recent Grafana versions and intercepts
              # OIDC user provisioning, causing "Failed to create user: user not
              # found". Disable it so the standard generic_oauth flow can create users.
              feature_toggles.enableSCIM = false;

              # OIDC-only login: hide the username/password form, do not auto-create
              # local users via signup, redirect straight to the OIDC provider.
              auth = {
                disable_login_form = true;
                signout_redirect_url = "${oidc.issuer}/api/oidc/end-session";
                # Self-healing OIDC user linking: if user_auth has no row for the
                # OIDC subject (e.g. fresh DB restore, or Authelia rebuilt and the
                # sub UUID changed), Grafana falls back to matching by email and
                # auto-creates the user_auth link. Safe here because Authelia is a
                # fully trusted IdP we control.
                oauth_allow_insecure_email_lookup = true;
              };
              users = {
                # Must be true so the OIDC provisioning path can create new users.
                # disable_login_form = true (above) already prevents the local signup
                # form from being rendered, so this only enables OIDC-initiated signup.
                allow_sign_up = true;
                auto_assign_org = true;
                auto_assign_org_role = "Admin";
              };
              "auth.generic_oauth" = {
                enabled = true;
                name = oidc.providerName;
                icon = "signin";
                auto_login = true;
                client_id = oidc.clientId;
                client_secret = "$__file{/run/credentials/grafana.service/oidc-secret}";
                scopes = "openid profile email groups";
                empty_scopes = false;
                auth_url = "${oidc.issuer}/authorize";
                token_url = "${oidc.issuer}/api/oidc/token";
                api_url = "${oidc.issuer}/api/oidc/userinfo";
                login_attribute_path = "preferred_username";
                email_attribute_path = "email";
                name_attribute_path = "name";
                groups_attribute_path = "groups";
                # Authelia already restricts who can reach the client via its
                # authorization policy, so anyone who successfully logs in is granted
                # Admin in Grafana.
                role_attribute_path = "'Admin'";
                allow_sign_up = true;
                use_pkce = true;
              };
            };

            provision = {
              enable = true;
              # TODO: provision dashboard
              datasources.settings.datasources = [
                {
                  name = "mimir";
                  url = "http://127.0.0.1:${toString config.services.mimir.configuration.server.http_listen_port}${config.services.mimir.configuration.server.http_path_prefix}${config.services.mimir.configuration.api.prometheus_http_prefix}";
                  type = "prometheus";
                  isDefault = true;
                  jsonData.manageAlerts = false;
                }
                {
                  name = "loki";
                  url = "http://127.0.0.1:${toString config.services.loki.configuration.server.http_listen_port}${config.services.loki.configuration.server.http_path_prefix}";
                  type = "loki";
                  jsonData.manageAlerts = false;
                }
              ];
            };
          };
        };
    };
  };

  roles.client = {
    description = "Collect and send metrics and logs to the server.";

    interface =
      { lib, ... }:
      {
        options = {
          monitoredSystemdServices = lib.mkOption {
            type = lib.types.either (lib.types.enum [
              "all"
              "nixos"
            ]) (lib.types.listOf lib.types.str);
            default = "nixos";
            description = ''
              List of systemd services which are shown in the clan infrastructure grafana dashboard.
              Logs sent to the monitoring server are filtered using this list.

              Options:
              "all" - all systemd services
              "nixos" (default) - services that have been explicitly enabled through nixos config
              listOf str - custom list of systemd services
            '';
            example = [
              "alloy.service"
              "grafana.service"
              "loki.service"
              "mimir.service"
              "nginx.service"
            ];
          };

          useSSL = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = ''
              Whether to send metrics data via http or https.
              Enable this if your monitoring server is addressable using https.
            '';
            example = false;
          };

          loki.journal.relabelRules.beforeNormalization = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = ''
              Additional Alloy `rule` blocks inserted into `loki.relabel "journal"`
              before the built-in label normalization rules.

              Use this for rules that need raw journal labels such as
              `__journal__*`.
            '';
            example = [
              ''
                rule {
                  source_labels = ["__journal_com_docker_swarm_service_name"]
                  regex = "^.*_(.*)$"
                  target_label = "oci_platform_service_name"
                }
              ''
            ];
          };

          loki.journal.relabelRules.afterNormalization = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = ''
              Additional Alloy `rule` blocks inserted into `loki.relabel "journal"`
              after the built-in label normalization rules.

              Use this for rules that depend on normalized labels such as
              `instance`, `service_name`, or `level`.
            '';
            example = [
              ''
                rule {
                  action = "drop"
                  source_labels = ["level"]
                  regex = "debug"
                }
              ''
            ];
          };
        };
      };

    perInstance =
      { roles, settings, ... }:
      {
        nixosModule =
          {
            config,
            lib,
            options,
            ...
          }:
          {
            services.alloy =
              let
                serverMachineCount = lib.length (lib.attrNames roles.server.machines);
                protocol = "http" + lib.optionalString settings.useSSL "s";
                serverSettings =
                  if serverMachineCount != 1 then
                    throw "The monitoring service requires exactly one server machine, but ${toString serverMachineCount} were defined."
                  else
                    (lib.head (lib.attrValues roles.server.machines)).settings;
                serverHost =
                  if serverSettings.host != null then
                    serverSettings.host
                  else
                    lib.head (
                      map (m: "${m}.${config.clan.core.settings.domain}") (lib.attrNames roles.server.machines)
                    );
                serverAddress = "${protocol}://${serverHost}";

                enabledNixosSystemdServices = map (v: "${v}.service") (
                  lib.attrNames (
                    lib.filterAttrs (_name: value: value) (
                      lib.mapAttrs (
                        name: value:
                        builtins.hasAttr "enable" options.services."${name}"
                        && builtins.hasAttr "default" options.services."${name}".enable
                        && options.services."${name}".enable.default != value.enable
                        && value.enable
                      ) config.services
                    )
                  )
                );

                monitorAllSystemdServices = settings.monitoredSystemdServices == "all";
                monitoredServices =
                  if settings.monitoredSystemdServices == "nixos" then
                    enabledNixosSystemdServices
                  else
                    settings.monitoredSystemdServices;
                monitoredServicesRegexFragments = map lib.escapeRegex monitoredServices;
                monitoredServicesRegex =
                  if monitoredServices == [ ] then
                    "^$"
                  else
                    "^(${lib.concatStringsSep "|" monitoredServicesRegexFragments})$";
                extraLokiJournalRelabelRulesBeforeNormalization = lib.concatStringsSep "\n" settings.loki.journal.relabelRules.beforeNormalization;
                extraLokiJournalRelabelRulesAfterNormalization = lib.concatStringsSep "\n" settings.loki.journal.relabelRules.afterNormalization;
              in
              {
                enable = true;
                extraFlags = [
                  "--server.http.enable-pprof=false"
                  "--disable-reporting=true"
                ];
                configPath = builtins.toFile "config.alloy" ''
                  // Collects metrics and sends them to mimir.
                  prometheus.exporter.unix "local_system" {
                    // See the list of available collectors in the alloy docs at
                    // https://grafana.com/docs/alloy/latest/reference/components/prometheus/prometheus.exporter.unix/#collectors-list
                    set_collectors = [ "cpu", "filesystem", "meminfo", "systemd" ]
                  }

                  prometheus.scrape "scrape_metrics" {
                    targets = prometheus.exporter.unix.local_system.targets
                    forward_to = [prometheus.relabel.create_nixos_services_metric.receiver, prometheus.remote_write.mimir.receiver]
                    scrape_interval = "10s"
                  }

                  prometheus.relabel "create_nixos_services_metric" {
                    forward_to = [prometheus.remote_write.mimir.receiver]

                    ${
                      if monitorAllSystemdServices then
                        ''
                          rule {
                            action = "keep"
                            source_labels = ["__name__"]
                            regex = "node_systemd_unit_state"
                          }
                        ''
                      else
                        ''
                          rule {
                            action = "keep"
                            source_labels = ["__name__", "name"]
                            regex = ${builtins.toJSON "node_systemd_unit_state;(${lib.concatStringsSep "|" monitoredServicesRegexFragments})"}
                          }
                        ''
                    }

                    rule {
                      action = "replace"
                      target_label = "__name__"
                      replacement = "nixos_systemd_unit_state"
                    }
                  }

                  prometheus.remote_write "mimir" {
                    endpoint {
                      url = "${serverAddress}/mimir/api/v1/push"
                      basic_auth {
                        username = "${config.clan.core.vars.generators.mimir-auth.files.username.value}"
                        password_file = sys.env("CREDENTIALS_DIRECTORY") + "/mimir-auth-password"
                      }
                    }
                  }

                  // Collects logs and sends them to loki.
                  loki.source.journal "all" {
                    relabel_rules = loki.relabel.journal.rules
                    forward_to = [loki.write.loki.receiver]
                  }

                  loki.relabel "journal" {
                    ${lib.optionalString (!monitorAllSystemdServices) ''
                      rule {
                        action = "keep"
                        source_labels = ["__journal__systemd_unit"]
                        regex = ${builtins.toJSON monitoredServicesRegex}
                      }
                    ''}
                    ${extraLokiJournalRelabelRulesBeforeNormalization}
                    rule {
                      source_labels = ["__journal__hostname"]
                      target_label = "instance"
                    }
                    rule {
                      source_labels = ["__journal__systemd_unit"]
                      target_label = "service_name"
                    }
                    rule {
                      source_labels = ["__journal_priority_keyword"]
                      target_label = "level"
                    }
                    ${extraLokiJournalRelabelRulesAfterNormalization}
                    forward_to = []
                  }

                  loki.write "loki" {
                    endpoint {
                      url = "${serverAddress}/loki/loki/api/v1/push"
                      basic_auth {
                        username = "${config.clan.core.vars.generators.loki-auth.files.username.value}"
                        password_file = sys.env("CREDENTIALS_DIRECTORY") + "/loki-auth-password"
                      }
                    }
                  }
                '';
              };

            environment.etc."alloy/config.alloy".source = config.services.alloy.configPath;

            systemd.services.alloy.serviceConfig = {
              ExecStart = lib.mkForce "${lib.getExe config.services.alloy.package} run /etc/alloy ${lib.escapeShellArgs config.services.alloy.extraFlags}";
              LoadCredential = [
                "mimir-auth-password:${config.clan.core.vars.generators.mimir-auth.files.password.path}"
                "loki-auth-password:${config.clan.core.vars.generators.loki-auth.files.password.path}"
              ];
            };
          };
      };
  };

  perMachine.nixosModule =
    { pkgs, ... }:
    {
      clan.core.vars.generators = {
        loki-auth = {
          share = true;

          files = {
            "username".secret = false;
            "password" = { };
            "htpasswd" = { };
          };

          runtimeInputs = [
            pkgs.openssl
            pkgs.apacheHttpd
          ];
          script = ''
            echo -n "alloy" > $out/username
            openssl rand -hex 32 > $out/password
            htpasswd -nbB "$(cat $out/username)" "$(cat $out/password)" > $out/htpasswd
          '';
        };

        mimir-auth = {
          share = true;

          files = {
            "username".secret = false;
            "password" = { };
            "htpasswd" = { };
          };

          runtimeInputs = [
            pkgs.openssl
            pkgs.apacheHttpd
          ];
          script = ''
            echo -n "alloy" > $out/username
            openssl rand -hex 32 > $out/password
            htpasswd -nbB "$(cat $out/username)" "$(cat $out/password)" > $out/htpasswd
          '';
        };
      };
    };

}
