{ lib, config, ... }:

let
  workspaces = (map toString (lib.range 0 9))
    ++ (map (n: "F${toString n}") (lib.range 1 12));
  # Map keys to hyprland directions
  directions = rec {
    left = "l";
    right = "r";
    up = "u";
    down = "d";
    h = left;
    l = right;
    k = up;
    j = down;
  };

  homeDir = config.home.homeDirectory;
in {
  wayland.windowManager.hyprland.settings = {
    "$LAUNCHER" = "${homeDir}/.config/rofi/scripts/launcher.sh";

    bindm = [ "SUPER,mouse:272,movewindow" "SUPER,mouse:273,resizewindow" ];

    bind = let swaylock = "${config.programs.swaylock.package}/bin/swaylock";
    in [
      "SUPER, T, exec, kitty"
      "SUPER, escape, exec, ${swaylock} -S"

      "SUPER, Q, killactive"
      "SUPER SHIFT, Q, exit"
      "SUPER, F, fullscreen"
      "SUPER, E, togglefloating"
      "SUPER, Space, exec, $LAUNCHER drun"
      "SUPER, P, pseudo"
      "SUPER, S, togglesplit"

      # Scroll workspace with mouse scrollwheel
      "SUPER, mouse_down, workspace, e+1"
      "SUPER, mouse_up, workspace, e-1"
    ] ++
    # Change workspace
    (map (n: "SUPER,${n},workspace,name:${n}") workspaces) ++
    # Move window to workspace
    (map (n: "SUPERSHIFT,${n},movetoworkspacesilent,name:${n}") workspaces) ++
    # Move focus
    (lib.mapAttrsToList (key: direction: "SUPER,${key},movefocus,${direction}")
      directions) ++
    # Swap windows
    (lib.mapAttrsToList
      (key: direction: "SUPERSHIFT,${key},swapwindow,${direction}") directions)
    ++
    # Move windows
    (lib.mapAttrsToList
      (key: direction: "SUPERCONTROL,${key},movewindoworgroup,${direction}")
      directions) ++
    # Move monitor focus
    (lib.mapAttrsToList
      (key: direction: "SUPERALT,${key},focusmonitor,${direction}") directions)
    ++
    # Move workspace to other monitor
    (lib.mapAttrsToList (key: direction:
      "SUPERALTSHIFT,${key},movecurrentworkspacetomonitor,${direction}")
      directions);
  };
}
