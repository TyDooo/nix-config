{
  config,
  pkgs,
  ...
}: {
  imports = [./keybinds.nix];

  home.packages = with pkgs; [swww];

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    enableNvidiaPatches = true; # TODO: only if on nvidia

    settings = import ./config.nix {inherit config;};
  };
}
