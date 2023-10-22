{ config, ... }:

let homeDir = config.home.homeDirectory;
in {
  wayland.windowManager.hyprland.settings = {
    "$LAUNCHER" = "${homeDir}/.config/rofi/scripts/launcher.sh";

    bindm = [ "SUPER,mouse:272,movewindow" "SUPER,mouse:273,resizewindow" ];

    bind = [
      "$MOD, T, exec, kitty"
      "$MOD, ESC, exec, swaylock"

      "$MOD, Q, killactive"
      "$MOD SHIFT, Q, exit"
      "$MOD, F, fullscreen"
      "$MOD, E, togglefloating"
      "$MOD, Space, exec, $LAUNCHER drun"
      "$MOD, P, pseudo"
      "$MOD, S, togglesplit"

      # Switch workspaces
      "$MOD, 1, workspace, 1"
      "$MOD, 2, workspace, 2"
      "$MOD, 3, workspace, 3"
      "$MOD, 4, workspace, 4"
      "$MOD, 5, workspace, 5"
      "$MOD, 6, workspace, 6"
      "$MOD, 7, workspace, 7"
      "$MOD, 8, workspace, 8"
      "$MOD, 9, workspace, 9"
      "$MOD, 0, workspace, 10"

      # Switch active window to workspace
      "$MOD SHIFT, 1, movetoworkspace, 1"
      "$MOD SHIFT, 2, movetoworkspace, 2"
      "$MOD SHIFT, 3, movetoworkspace, 3"
      "$MOD SHIFT, 4, movetoworkspace, 4"
      "$MOD SHIFT, 5, movetoworkspace, 5"
      "$MOD SHIFT, 6, movetoworkspace, 6"
      "$MOD SHIFT, 7, movetoworkspace, 7"
      "$MOD SHIFT, 8, movetoworkspace, 8"
      "$MOD SHIFT, 9, movetoworkspace, 9"
      "$MOD SHIFT, 0, movetoworkspace, 10"

      # Scroll workspace with mouse scrollwheel
      "$MOD, mouse_down, workspace, e+1"
      "$MOD, mouse_up, workspace, e-1"
    ];
  };
}
