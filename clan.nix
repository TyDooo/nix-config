{ inputs, ... }:
let
  inherit (self) outputs;
  inherit (inputs) self;

  modulePath = ./modules;

  common = modulePath + /common;

  # ROLES
  rolesPath = modulePath + /roles;

  server = rolesPath + /server;
  admin = rolesPath + /admin;
  graphical = rolesPath + /graphical;
  gaming = rolesPath + /gaming;
  headless = rolesPath + /headless;
in
{
  imports = [
    inputs.clan-core.flakeModules.default
  ];

  clan = {
    inherit self;

    specialArgs = {
      inherit outputs;
      inherit inputs self;
    };

    meta.name = "grimoire";
    meta.domain = "spell";

    secrets.age.plugins = [
      "age-plugin-yubikey"
    ];

    modules."@grimoire/nfs" = ./clanServices/nfs;
    modules."@grimoire/shoko" = ./clanServices/shoko;
    modules."@grimoire/blocky" = ./clanServices/blocky;
    modules."@grimoire/monitoring" = ./clanServices/monitoring;

    exportInterfaces.metrics = import ./clanServices/monitoring/metrics-interface.nix;

    inventory = {
      machines = {
        zoltraak.tags = [
          "headless"
          "server"
        ];

        catastravia.tags = [
          "headless"
          "server"
        ];

        sorganeil.tags = [
          "headless"
        ];

        judradjim.tags = [
          "admin"
          "desktop"
          "graphical"
          "gaming"
        ];

        nephtear.tags = [
          "admin"
          "graphical"
          "gaming"
        ];
      };

      instances = {
        user-root = {
          module.name = "users";
          roles.default.tags.all = { };
          roles.default.settings = {
            user = "root";
            prompt = false;
            openssh.authorizedKeys.keyFiles = [ ./users/ssh.pub ];
          };
        };

        user-tydooo = {
          module.name = "users";
          roles.default.tags.all = { };
          roles.default.settings = {
            user = "tydooo";
            share = true;
            openssh.authorizedKeys.keyFiles = [ ./users/ssh.pub ];
          };
          roles.default.extraModules = [ ./users/tydooo/user.nix ];
        };

        sshd-basic = {
          module.name = "sshd";
          roles.server.tags.all = { };
          roles.client.tags.all = { };
        };

        base = {
          module.name = "importer";
          roles.default.tags = [ "all" ];
          roles.default.extraModules = [
            inputs.home-manager.nixosModules.home-manager

            common

            ./modules
          ];
        };

        headless = {
          module.name = "importer";
          roles.default.tags = [ "headless" ];
          roles.default.extraModules = [ headless ];
        };

        server = {
          module.name = "importer";
          roles.default.tags = [ "server" ];
          roles.default.extraModules = [ server ];
        };

        admin = {
          module.name = "importer";
          roles.default.tags = [ "admin" ];
          roles.default.extraModules = [ admin ];
        };

        graphical = {
          module.name = "importer";
          roles.default.tags = [ "graphical" ];
          roles.default.extraModules = [ graphical ];
        };

        gaming = {
          module.name = "importer";
          roles.default.tags = [ "gaming" ];
          roles.default.extraModules = [ gaming ];
        };

        zoltraak-shoko = {
          module.input = "self";
          module.name = "@grimoire/shoko";
          roles.default.machines.zoltraak = { };
        };

        emergency-access = {
          module.name = "emergency-access";
          roles.default.tags.nixos = { };
        };

        clan-cache = {
          module.name = "trusted-nix-caches";
          roles.default.tags.all = { };
        };

        data-mesher = {
          module.name = "data-mesher";
          # All machines participate in the mesh
          roles.default.tags.all = { };
          roles.default.settings.interfaces = [
            "ztt3kigr5l"
            "ygg"
          ];
          # Always-on servers act as bootstrap entry points
          roles.bootstrap.tags.server = { };
        };

        dm-dns = {
          module.name = "dm-dns";
          roles.default.tags.all = { };
          roles.push.machines.judradjim = { };
          roles.push.machines.zoltraak = { };
        };

        pki = {
          module.name = "pki";
          roles.default.tags = [ "all" ];
        };

        internet = {
          module.name = "internet";
          roles.default.tags.server = { };
          roles.default.machines = {
            zoltraak.settings.host = "10.10.50.50";
            catastravia.settings.host = "46.224.129.105";
          };
        };

        zerotier = {
          roles.controller.machines.catastravia = { };
          roles.peer.tags = [ "all" ];
        };

        yggdrasil = {
          roles.default.tags = [ "all" ];
        };

        wifi = {
          module.name = "wifi";
          roles.default.machines.nephtear = {
            settings.networks.home = { };
          };
        };

        nfs = {
          module.input = "self";
          module.name = "@grimoire/nfs";

          roles.server.machines.zoltraak.settings.shares = {
            # NOTE: the "fsid=" option is needed for the sauce and
            #       downloads shares as these user mergerfs and do
            #       not get an inferred fsid assigned. The music
            #       shares has this option for consitency.
            music = {
              source = "/mnt/disks/tank/media/music";
              options = "rw,nohide,fsid=1";
            };
            sauce = {
              source = "/mnt/user/sauce";
              options = "rw,nohide,fsid=2";
            };
            downloads = {
              source = "/mnt/user/downloads";
              options = "rw,nohide,fsid=3";
            };
          };
          roles.client.machines.judradjim.settings.mounts = {
            music = {
              server = "zoltraak";
              share = "music";
              path = "/mnt/user/music";
            };
            sauce = {
              server = "zoltraak";
              share = "sauce";
              path = "/mnt/user/sauce";
            };
            downloads = {
              server = "zoltraak";
              share = "downloads";
              path = "/mnt/user/downloads";
            };
          };
        };

        borgbackup =
          let
            mkHetznerStoragebox = username: {
              "storagebox" = {
                repo = "${username}@${username}.your-storagebox.de:/./borgbackup";
                rsh = "ssh -p 23 -oStrictHostKeyChecking=accept-new -i /run/secrets/vars/borgbackup/borgbackup.ssh";
              };
            };
          in
          {
            roles.client.machines.zoltraak.settings = {
              destinations = mkHetznerStoragebox "u330276-sub2";
              startAt = "*-*-* 03:00:00";
            };
            roles.client.machines.catastravia.settings = {
              destinations = mkHetznerStoragebox "u330276-sub3";
              startAt = "*-*-* 04:00:00";
            };
          };

        blocky = {
          module.input = "self";
          module.name = "@grimoire/blocky";

          roles.default.machines.zoltraak.settings = {
            listenAddresses = [ "10.10.50.50" ];
          };
          roles.default.machines.sorganeil = { };

          roles.cache.machines.zoltraak = { };
        };

        pocket-id = {
          module.input = "clan-community";
          module.name = "pocket-id";
          roles.default.machines.catastravia.settings = {
            publicHost = "auth.tydooo.dev";
            extraClients.tandoor = {
              name = "Tandoor Recipes";
              callbackURLs = [
                "http://10.10.50.50:8174/accounts/oidc/pocket-id/login/callback/"
              ];
              isPublic = true;
            };
          };
        };

        monitoring = {
          module.input = "self";
          module.name = "@grimoire/monitoring";

          roles.server.machines.catastravia.settings = {
            grafana.oidc = {
              enable = true;
              issuer = "https://auth.tydooo.dev";
              clientId = "grafana";
              providerName = "Pocket ID";
            };
          };
          roles.client.tags.headless = { };
        };
      };
    };
  };
}
