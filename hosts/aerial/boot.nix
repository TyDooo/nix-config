{pkgs, ...}: {
  boot = {
    initrd = {
      systemd.enable = true;
      supportedFilesystems = ["btrfs"];
    };

    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
        consoleMode = "max"; # force the use of the max monitor resolution. default is "keep".
      };
      efi.canTouchEfiVariables = true;
    };

    # # Enable "Silent Boot"
    # consoleLogLevel = 0;
    # initrd.verbose = false;
    # kernelParams = [
    #   "quiet"
    #   "splash"
    #   "boot.shell_on_fail"
    #   "loglevel=3"
    #   "rd.systemd.show_status=false"
    #   "rd.udev.log_level=3"
    #   "udev.log_priority=3"
    # ];

    # # Hide the OS choice for bootloaders.
    # # It's still possible to open the bootloader list by pressing any key
    # # It will just not appear on screen unless a key is pressed
    # loader.timeout = 0;

    # plymouth = {
    #   enable = true;
    #   # https://github.com/adi1090x/plymouth-themes
    #   theme = "rog_2";
    #   themePackages = with pkgs; [
    #     (adi1090x-plymouth-themes.override {
    #       selected_themes = ["rog_2"];
    #     })
    #   ];
    # };
  };

  # # make plymouth work with sleep
  # powerManagement = {
  #   powerDownCommands = ''
  #     ${pkgs.plymouth} --show-splash
  #   '';
  #   resumeCommands = ''
  #     ${pkgs.plymouth} --quit
  #   '';
  # };
}
