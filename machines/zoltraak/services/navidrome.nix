{ config, pkgs, ... }:
let
  dataPath = "/var/lib/navidrome";
  musicPath = "/mnt/user/media/music";

  navidrome-lyrics-plugin = pkgs.stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "navidrome-lyrics-plugin";
    version = "7.1.0";

    src = pkgs.fetchurl {
      url = "https://github.com/J0R6IT0/navidrome-lyrics-plugin/releases/download/v${finalAttrs.version}/nd-lyrics.ndp";
      hash = "sha256-N0OJ0GuTWISvCjooxttRDl6O5GYDOomcPH6yClSFLOc=";
    };

    dontUnpack = true;

    installPhase = ''
      mkdir -p $out/share
      cp $src $out/share/${finalAttrs.pname}.ndp
    '';

    passthru.isNavidromePlugin = true;
  });
in
{
  services.navidrome = {
    enable = true;

    settings = {
      Port = 4533;
      Address = "0.0.0.0";

      MusicFolder = musicPath;

      EnableInsightsCollector = false;
      EnableStarRating = false;
      PluginsEnabled = true;
      EnableSharing = true;

      Plugins.Enabled = true;

      Agents = "audiomuseai,apple-music,deezer,lastfm,listenbrainz";
      LyricsPriority = ".ttml,.yaml,.yml,.elrc,.lrc,.srt,.txt,embedded,nd-lyrics";
    };

    plugins =
      with pkgs.navidromePlugins;
      [
        apple-music
        audiomuseai
      ]
      ++ [
        navidrome-lyrics-plugin
      ];
  };

  systemd.tmpfiles.rules = [
    "d ${musicPath} 2755 tydooo media - -"
  ];

  systemd.services.navidrome = {
    serviceConfig.RequiresMountsFor = "${musicPath}";
  };

  # Add the navidrome user to the media group to allow access to the library
  users.users.navidrome.extraGroups = [ "media" ];

  environment.persistence."/persist".directories = [
    {
      directory = dataPath;
      inherit (config.services.navidrome) user group;
      mode = "0750";
    }
  ];

  clan.core.state.navidrome = {
    folders = [ dataPath ];
    preBackupScript = ''
      systemctl stop navidrome.service
    '';
    postBackupScript = ''
      systemctl start navidrome.service
    '';
  };
}
