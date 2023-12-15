{config, ...}: let
  pointer = config.home.pointerCursor;
in {
  exec-once = [
    "hyprctl setcursor ${pointer.name} ${toString pointer.size}"
    "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
    "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
    "waybar"
    "swww init"
  ];
  exec = ["swww img ${toString config.wallpaper}"];
  xwayland.force_zero_scaling = true;
  env = [
    "XDG_SESSION_TYPE,wayland"
    "WLR_NO_HARDWARE_CURSORS,1"
  ];

  input = {
    kb_layout = "us";
    follow_mouse = 1;
    sensitivity = 0; # -1.0 - 1.0, 0 means no modification.
    force_no_accel = 1;
  };

  general = {
    gaps_in = 4;
    gaps_out = 12;
    border_size = 2;
    "col.active_border" = "0xffcba6f7";
    "col.inactive_border" = "0xff313244";
    no_border_on_floating = true;
    layout = "dwindle";
    # TODO: Check if this can be put at a nicer spot
    monitor =
      map (m: let
        name =
          if builtins.isNull m.desc
          then "${m.name}"
          else "desc:${m.desc}";
        resolution = "${toString m.width}x${toString m.height}@${toString m.refreshRate}";
        position = "${toString m.x}x${toString m.y}";
        transform = "transform,${toString m.transform}";
      in "${name},${
        if m.enabled
        then "${resolution},${position},1,${transform}"
        else "disable"
      }")
      config.monitors;
  };

  misc = {
    disable_hyprland_logo = true;
    disable_splash_rendering = true;
    mouse_move_enables_dpms = true;
    enable_swallow = true;
    swallow_regex = "^(kitty)$";
  };

  decoration = {
    # Rounded corners
    rounding = 4;
    multisample_edges = true;

    # Opacity
    active_opacity = 1.0;
    inactive_opacity = 1.0;

    blur = {
      size = 10;
      passes = 4;
      new_optimizations = true;
    };
    blurls = ["gtk-layer-shell" "waybar" "lockscreen"];

    # Shadow
    drop_shadow = true;
    shadow_ignore_window = true;
    shadow_offset = "2 2";
    shadow_range = 4;
    shadow_render_power = 2;
    "col.shadow" = "0x66000000";
  };

  animations = {
    enabled = true;
    bezier = [
      "easein,0.11, 0, 0.5, 0"
      "easeout,0.5, 1, 0.89, 1"
      "easeinback,0.36, 0, 0.66, -0.56"
      "easeoutback,0.34, 1.56, 0.64, 1"
    ];

    animation = [
      "windowsIn,1,3,easeoutback,slide"
      "windowsOut,1,3,easeinback,slide"
      "windowsMove,1,3,easeoutback"
      "workspaces,1,2,easeoutback,slide"
      "fadeIn,1,3,easeout"
      "fadeOut,1,3,easein"
      "fadeSwitch,1,3,easeout"
      "fadeShadow,1,3,easeout"
      "fadeDim,1,3,easeout"
      "border,1,3,easeout"
    ];
  };

  dwindle = {
    # "col.group_border_active" = "0xff89b4fa";
    # "col.group_border" = "0xff585b70";
    no_gaps_when_only = true;
    pseudotile =
      true; # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
    preserve_split = true; # you probably want this
  };
}
