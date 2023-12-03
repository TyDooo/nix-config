{pkgs, ...}: {
  programs.rofi = {
    enable = true;
    terminal = "${pkgs.kitty}/bin/kitty";
    plugins = [pkgs.rofi-emoji];
  };

  home.file = {
    ".config/rofi" = {
      recursive = true;
      source = ./config;
    };

    ".config/rofi/scripts/launcher.sh" = {
      source = ./scripts/launcher.sh;
      executable = true;
    };

    ".config/rofi/scripts/power.sh" = {
      source = ./scripts/power.sh;
      executable = true;
    };
  };
}
