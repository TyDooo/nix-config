{
  flake.nixosModules.base = {
    services.fail2ban = {
      enable = true;

      ignoreIP = [
        "127.0.0.0/8" # localhost
        "10.0.0.0/8" # local network
      ];

      daemonSettings = {
        Definition = {
          loglevel = "INFO";
          logtarget = "/var/log/fail2ban/fail2ban.log";
          socket = "/run/fail2ban/fail2ban.sock";
          pidfile = "/run/fail2ban/fail2ban.pid";
          dbfile = "/var/lib/fail2ban/fail2ban.sqlite3";
          dbpurageage = "1d";
        };
      };
    };
  };
}
