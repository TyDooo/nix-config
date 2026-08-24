{ inputs, ... }: {
  perSystem = { pkgs, ... }: {
    packages.kitty-wrapped = inputs.wrapper-modules.wrappers.kitty.wrap {
      inherit pkgs;

      font = {
        size = 10;
        name = "JetBrainsMono Nerd Font";
      };

      settings = {
        enable_audio_bell = false;
        copy_on_select = "clipboard";
        confirm_os_window_close = 0;
      };

      themeFile = "rose-pine";
    };
  };
}
