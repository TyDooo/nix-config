{
  _class = "clan.service";

  manifest.name = "nfs";
  manifest.description = "NFSv4 server with auto-generated bind-mount exports, plus matching client mounts.";
  manifest.readme = builtins.readFile ./README.md;
  manifest.categories = [
    "System"
    "Network"
  ];

  manifest.constraints.maxInstances = 1;

  roles.server = {
    description = "Exports NFS shares to be mounted by clients.";

    interface =
      { lib, ... }:
      let
        inherit (lib) types;
      in
      {
        options = {
          basePath = lib.mkOption {
            type = types.str;
            default = "/export";
            description = "Base directory for the NFS export tree (NFSv4 pseudo-root, fsid=0).";
          };

          shares = lib.mkOption {
            type = types.attrsOf (
              types.submodule {
                options = {
                  source = lib.mkOption {
                    type = types.str;
                    description = "Source path to bind mount into the export tree.";
                  };
                  options = lib.mkOption {
                    type = types.str;
                    default = "rw,nohide";
                    description = "NFS export options for this share.";
                  };
                };
              }
            );
            default = { };
            example = {
              music.source = "/mnt/user/music";
              data.source = "/mnt/data";
            };
            description = "Attribute set of shares. Keys become subdirectory names under basePath.";
          };
        };
      };

    perInstance =
      {
        settings,
        roles,
        meta,
        ...
      }:
      {
        nixosModule =
          { lib, ... }:
          let
            cfg = settings;

            # Every machine assigned the "client" role on this instance is
            # automatically allowed to mount these exports.
            #
            # TODO: limit to only the clients that request this export
            clientNames = lib.attrNames roles.client.machines;

            clientExportStr =
              opts: lib.concatMapStringsSep " " (client: "${client}.${meta.domain}(${opts})") clientNames;

            exportLines = lib.concatStringsSep "\n" (
              [ "${cfg.basePath}  ${clientExportStr "rw,fsid=0"}" ] # NFSv4 pseudo-root
              ++ lib.mapAttrsToList (
                name: share: "${cfg.basePath}/${name}  ${clientExportStr share.options}"
              ) cfg.shares
            );
          in
          {
            systemd.tmpfiles.rules = [
              "d ${cfg.basePath} 0755 nobody nogroup - -"
            ];

            # Bind mount every declared share under the export tree
            fileSystems = lib.mapAttrs' (
              name: share:
              lib.nameValuePair "${cfg.basePath}/${name}" {
                device = share.source;
                fsType = "none";
                options = [ "bind" ];
              }
            ) cfg.shares;

            services.nfs.server.exports = exportLines;
          };
      };
  };

  roles.client = {
    description = "Mounts NFS shares exported by the servers.";

    interface =
      { lib, ... }:
      let
        inherit (lib) types;
      in
      {
        options.mounts = lib.mkOption {
          type = types.attrsOf (
            types.submodule {
              options = {
                server = lib.mkOption {
                  type = types.str;
                  description = "Hostname or IP of the NFS server machine to mount from.";
                };
                share = lib.mkOption {
                  type = types.str;
                  description = "Name of the share, as declared under the server's `shares`.";
                };
                path = lib.mkOption {
                  type = types.str;
                  description = "Local mountpoint for this share.";
                };
                options = lib.mkOption {
                  type = types.str;
                  default = "rw,_netdev,x-systemd.automount,x-systemd.idle-timeout=600,noatime,vers=4.2";
                  description = "Mount options used for this NFS mount.";
                };
              };
            }
          );
          default = { };
          example = {
            music = {
              server = "zoltraak";
              share = "music";
              path = "/mnt/user/music";
            };
          };
          description = "Attribute set of NFS shares to mount on this client.";
        };
      };

    perInstance =
      { settings, meta, ... }:
      {
        nixosModule =
          { lib, ... }:
          {
            fileSystems = lib.mapAttrs' (
              _name: mount:
              lib.nameValuePair mount.path {
                device = "${mount.server}.${meta.domain}:/${mount.share}";
                fsType = "nfs";
                options = lib.splitString "," mount.options;
              }
            ) settings.mounts;
          };
      };
  };

  perMachine =
    { machine, ... }:
    {
      nixosModule =
        { lib, ... }:
        let
          isServer = lib.elem "server" machine.roles;
        in
        lib.mkIf isServer {
          services.nfs.server.enable = true;
          # Only NFSv4 - no UDP, no v2/v3
          services.nfs.settings.nfsd = {
            UDP = "off";
            vers2 = "off";
            vers3 = "off";
          };

          environment.persistence."/persist".directories = [
            { directory = "/var/lib/nfs"; }
          ];

          networking.firewall.allowedTCPPorts = [ 2049 ];
          networking.firewall.allowedUDPPorts = [ 2049 ];
        };
    };
}
