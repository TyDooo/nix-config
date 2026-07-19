{ pkgs, ... }: {
  boot = {
    initrd.availableKernelModules = [
      "xhci_pci"
      "usbhid"
      "usb_storage"
    ];
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
  };

  # Disable DNSStubListener to free up port 53 for Blocky
  services.resolved.settings.Resolve.DNSStubListener = false;

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  networking = {
    hostName = "sorganeil";
    interfaces.end0.ipv6.addresses = [
      {
        address = "fdfa:eded:1c37:50::51";
        prefixLength = 64;
      }
    ];
  };

  environment.systemPackages = with pkgs; [
    libraspberrypi
    raspberrypi-eeprom
  ];

  hardware.enableRedistributableFirmware = true;
}
