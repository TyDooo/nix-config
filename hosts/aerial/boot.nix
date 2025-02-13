{pkgs, ...}: {
  boot = {
    initrd = {
      systemd.enable = true;
      supportedFilesystems = ["btrfs"];
    };

    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    # consoleLogLevel = 3;
    # kernelParams = [
    #   "quiet"
    #   "systemd.show_status=auto"
    #   "rd.udev.log_level=3"
    #   "plymouth.use-simpledrm"
    # ];

    # plymouth.enable = true;
  };
}
