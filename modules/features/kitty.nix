{ inputs, ... }: {
  perSystem = { pkgs, ... }: {
    packages.myKitty = inputs.wrapper-modules.wrappers.kitty.wrap {
      inherit pkgs;

      font = {
        size = 10;
        name = "JetBrainsMono Nerd Font";
      };

      settings = {
        enable_audio_bell = false;
      };

      # FIXME: this won't work on other machines
      extraConfig = ''
        include ~/.config/kitty/current-theme.conf
      '';
    };
  };
}
