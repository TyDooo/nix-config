{
  programs.kitty = {
    enable = true;
    themeFile = "tokyo_night_night";
    font.name = "JetBrainsMono Nerd Font Mono";
    shellIntegration.enableZshIntegration = true;
    shellIntegration.enableBashIntegration = true;
    settings = {
      background_opacity = "0.9";
      window_padding_width = "12 12 0 12";
    };
  };
}
