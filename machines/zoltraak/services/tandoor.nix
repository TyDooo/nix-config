{ config, pkgs, ... }:
let
  database_db = "tandoor_recipes";
  database_user = "tandoor_recipes";
in
{
  services.tandoor-recipes = {
    enable = true;
    port = 8174;
    address = "10.10.50.50";
    extraConfig = {
      DB_ENGINE = "django.db.backends.postgresql";
      POSTGRES_HOST = "/run/postgresql";
      POSTGRES_USER = database_user;
      POSTGRES_DB = database_db;
      SECRET_KEY_FILE = config.clan.core.vars.generators.tandoor-recipes-secret-key.files.key.path;
      MEDIA_ROOT = "/var/lib/tandoor-recipes";

      ALLOWED_HOSTS = "10.10.50.50,127.0.0.1,localhost";
      SOCIAL_PROVIDERS = "allauth.socialaccount.providers.openid_connect";
      SOCIALACCOUNT_PROVIDERS = builtins.toJSON {
        openid_connect = {
          OAUTH_PKCE_ENABLED = true;
          APPS = [
            {
              provider_id = "pocket-id";
              name = "Pocket ID";
              client_id = "tandoor";
              secret = "";
              settings.server_url = "https://auth.tydooo.dev/.well-known/openid-configuration";
            }
          ];
        };
      };
    };
  };

  clan.core.postgresql = {
    enable = true;
    users.${database_user} = { };
    databases.${database_db} = {
      create.options = {
        TEMPLATE = "template0";
        LC_COLLATE = "C";
        LC_CTYPE = "C";
        ENCODING = "UTF8";
        OWNER = database_user;
      };
      restore.stopOnRestore = [ "tandoor-recipes" ];
    };
  };

  clan.core.vars.generators = {
    tandoor-recipes-secret-key = {
      files.key = {
        secret = true;
        owner = config.services.tandoor-recipes.user;
        mode = "0400";
      };
      runtimeInputs = with pkgs; [
        coreutils
        openssl
      ];
      script = ''
        openssl rand -base64 50 > $out/key
      '';
    };
  };

  clan.core.state."shoko" = {
    folders = [ "/var/lib/tandoor-recipes" ];
    preBackupScript = ''
      systemctl stop tandoor-recipes.service
    '';
    postBackupScript = ''
      systemctl start tandoor-recipes.service
    '';
  };

  environment.persistence = {
    "/persist".directories = [
      {
        directory = "/var/lib/tandoor-recipes";
        inherit (config.services.tandoor-recipes) user group;
      }
    ];
  };

  networking.firewall.allowedTCPPorts = [ config.services.tandoor-recipes.port ];
}
