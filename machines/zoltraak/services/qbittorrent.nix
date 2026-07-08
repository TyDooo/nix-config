{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) singleton getExe;

  port = 8182;
  media_dir = "/mnt/user/media";
  torrents_dir = "/mnt/user/downloads/torrents";

  anime_import = pkgs.writeShellScriptBin "qbit_anime_import" ''
    # bash
    set -euo pipefail

    IMPORT_DIR="${media_dir}/import/anime"
    LOG_FILE="${media_dir}/import/import.log"

    mkdir -p "$IMPORT_DIR" "$(dirname "$LOG_FILE")"

    CATEGORY="''${1,,}"
    CONTENT_PATH="$2"

    log() {
        echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
    }

    # Only process torrents in the "anime" category
    if [[ "$CATEGORY" != "anime" ]]; then
        exit 0
    fi

    if [[ ! -e "$CONTENT_PATH" ]]; then
        log "Error: Source path not found: $CONTENT_PATH"
        exit 1
    fi

    NAME=$(basename "$CONTENT_PATH")
    DEST_PATH="$IMPORT_DIR/$NAME"

    # Copy with hard-links (-l), recursive (-R), force (-f)
    if ! cp -lRf "$CONTENT_PATH" "$IMPORT_DIR/"; then
      log "Hard-link failed, falling back to regular copy: $NAME"
      cp -Rf "$CONTENT_PATH" "$IMPORT_DIR/"
    fi
    EXIT_CODE=$?

    if [ $EXIT_CODE -eq 0 ]; then
        log "Imported: $NAME"
    else
        log "Error: Failed to link '$NAME'. Exit Code: $EXIT_CODE"
    fi
  '';
in
{
  services.qbittorrent = {
    enable = true;
    group = "media";
    package = pkgs.qbittorrent-nox;
    webuiPort = port;
    serverConfig = {
      LegalNotice.Accepted = true;
      BitTorrent = {
        Session = {
          DisableAutoTMMByDefault = false;
          DisableAutoTMMTriggers = {
            CategorySavePathChanged = false;
            DefaultSavePathChanged = false;
          };
          MaxActiveTorrents = 20;
          MaxActiveDownloads = 3;
          MaxActiveUploads = 3;
          GlobalMaxRatio = 1;
          GlobalMaxSeedingMinutes = 2880;
          Preallocation = true;
          QueueingSystemEnabled = true;
          IgnoreSlowTorrentsForQueueing = true;
        };
      };
      Preferences = {
        Downloads = {
          SavePath = torrents_dir;
          TempPath = "${torrents_dir}/.incomplete";
          TempPathEnabled = true;
        };
        WebUI = {
          Username = "admin";
          Password_PBKDF2 = "@ByteArray(CoN9QpoAVRjklid65alTCw==:Iut59EjN2G9vrFcDwSFASc2xxt5F/TK3N3nFQEO3rEGHBj7Z0Cy61uNmS3Gy2bCk0bNIG+PMp20yOYwkBkcxyg==)";
          LocalHostAuth = false;
          UseUPnP = false;
        };
      };
      AutoRun = {
        enabled = true;
        program = "${getExe anime_import} \\\"%L\\\" \\\"%F\\\"";
      };
      RSS = {
        AutoDownloader = {
          DownloadRepacks = true;
          EnableProcessing = true;
        };
        Session.EnableProcessing = true;
      };
    };
  };

  users.users.qbittorrent.extraGroups = [ "media" ];

  # Tunnel all traffic through Proton VPN
  systemd.services.qbittorrent = {
    # vpnConfinement sets `bindsTo` and `after` automatically
    vpnConfinement = {
      enable = true;
      vpnNamespace = "proton0";
    };
    serviceConfig.UMask = "0002";
  };

  systemd.tmpfiles.rules = [
    "d ${torrents_dir}                 2770 qbittorrent media - -"
    "d ${torrents_dir}/movies          2770 qbittorrent media - -"
    "d ${torrents_dir}/shows           2770 qbittorrent media - -"
    "d ${torrents_dir}/music           2770 qbittorrent media - -"
    "d ${torrents_dir}/sauce           2770 qbittorrent media - -"
    "d ${torrents_dir}/anime           2770 qbittorrent media - -"
    "d ${torrents_dir}/.incomplete     2770 qbittorrent media - -"
  ];

  environment.persistence = {
    "/persist".directories = [
      {
        directory = config.services.qbittorrent.profileDir;
        inherit (config.services.qbittorrent) user group;
        mode = "0750";
      }
    ];
  };

  clan.core.state.qbittorrent = {
    folders = [ config.services.qbittorrent.profileDir ];
    preBackupScript = ''
      systemctl stop qbittorrent.service
    '';
    postBackupScript = ''
      systemctl start qbittorrent.service
    '';
  };

  vpnNamespaces.proton0.portMappings = singleton {
    from = port;
    to = port;
    protocol = "tcp";
  };

  networking.firewall.allowedTCPPorts = [ port ];
}
