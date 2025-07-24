{
  inputs',
  self',
  pkgs,
  ...
}: {
  imports = [
    ../common/optional/nvidia.nix
    ../common/optional/gnome.nix
    ../common/optional/fonts.nix
    ../common/optional/pipewire.nix
    ../common/optional/plymouth.nix

    ./modules/amd-cpu.nix
    ./modules/mounts.nix
  ];

  networking = {
    networkmanager.enable = true;
  };

  environment.systemPackages = with pkgs; [
    wget
    helix
    git
    self'.packages.nvim
    inputs'.zen-browser.packages.default
  ];

  boot = {
    initrd = {
      systemd.enable = true;
      supportedFilesystems = ["btrfs"];
    };

    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };

      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
      };
    };

    # FIXME: This seems to cause issues with suspending/resuming.
    # kernelPackages = pkgs.linuxPackages_cachyos;
  };

  services.hardware.openrgb.enable = true;

  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
    };

    gamemode.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
  };

  systemd.tmpfiles.rules = [
    # type path        mode  user      group  age argument
    "d    /mnt/games   0775  tygo  users  -   -"
  ];

  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = ["tygo"];
  boot.kernelParams = ["kvm.enable_virt_at_load=0"];

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?
}
