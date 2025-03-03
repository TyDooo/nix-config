{pkgs, ...}: {
  fonts = {
    enableDefaultPackages = false;

    fontconfig = {
      enable = true;
      hinting.enable = true;
      antialias = true;
    };

    fontDir = {
      enable = true;
      decompressFonts = true;
    };

    packages = with pkgs; [
      # defaults worth keeping
      dejavu_fonts
      freefont_ttf
      gyre-fonts
      liberation_ttf # for PDFs, Roman
      unifont
      roboto

      # programming fonts
      sarasa-gothic
      (nerdfonts.override {fonts = ["JetBrainsMono"];})

      # desktop fonts
      corefonts # MS fonts
      b612 # high legibility
      material-icons # used in widgets and such
      material-design-icons
      work-sans
      comic-neue
      source-sans
      inter
      lato
      lexend
      dejavu_fonts
      noto-fonts
      noto-fonts-cjk-sans

      # emojis
      noto-fonts-color-emoji
      twemoji-color-font
      openmoji-color
      openmoji-black
    ];
  };
}
