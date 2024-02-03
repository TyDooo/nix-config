{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  cfg = config.services.mover;
in {
  options.services.mover = {
    enable = mkEnableOption (mdDoc "Mover service");

    cache = mkOption {
      type = types.str;
      default = "/mnt/cache";
      description = "Cache directory";
    };

    target = mkOption {
      type = types.str;
      default = "/mnt/target";
      description = "Target directory";
    };

    daysOld = mkOption {
      type = types.str;
      default = "1";
      description = "Minimum age of files to move";
    };

    interval = mkOption {
      type = types.str;
      default = "hourly";
      description = "Interval between moves";
    };
  };

  config = mkIf cfg.enable {
    systemd.timers.mover = {
      wantedBy = ["timers.target"];
      partOf = ["mover.service"];
      timerConfig = {
        OnCalendar = cfg.interval;
        Unit = "mover.service";
      };
    };

    systemd.services.mover = {
      path = [pkgs.mover pkgs.util-linux];
      script = "mover ${cfg.cache} ${cfg.target} ${cfg.daysOld}";
      serviceConfig.Type = "oneshot";
    };
  };
}
