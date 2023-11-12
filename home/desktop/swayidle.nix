{ config, ... }:

let
  swaylock = "${config.programs.swaylock.package}/bin/swaylock";

  lockTime = 10 * 60;
in {
  services.swayidle = {
    enable = true;
    systemdTarget = "graphical-session.target";
    timeouts = [{
      timeout = lockTime;
      command = "${swaylock} --daemonize";
    }];
  };
}
