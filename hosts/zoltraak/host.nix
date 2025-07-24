{
  config,
  self',
  pkgs,
  ...
}: {
  imports = [
    ./services/navidrome.nix
    ./services/jellyfin.nix
    ./services/newt.nix
    ./services/pocket-id.nix
  ];

  networking = {
    networkmanager.enable = true;
  };

  environment.systemPackages = with pkgs; [
    wget
    helix
    git
    self'.packages.nvim
  ];

  boot = {
    initrd = {
      systemd.enable = true;
      supportedFilesystems = ["btrfs"];
    };

    loader.systemd-boot.enable = true;
  };

  services.qemuGuest.enable = true;

  fileSystems = let
    commonOptions = [
      "credentials=${config.sops.secrets."smb-creds".path}"
      "x-systemd.automount"
      "uid=2000"
      "gid=2000"
      "file_mode=0664"
      "dir_mode=0775"
      "noauto"
    ];
  in {
    "/mnt/music" = {
      device = "//192.168.50.20/music";
      fsType = "cifs";
      options = commonOptions;
    };

    "/mnt/media" = {
      device = "//192.168.50.20/media";
      fsType = "cifs";
      options = commonOptions;
    };
  };

  sops.secrets."smb-creds" = {};

  users = {
    users.shared = {
      isSystemUser = true;
      group = "shared";
      uid = 2000;
    };
    groups.shared.gid = 2000;
  };

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
  system.stateVersion = "24.11"; # Did you read the comment?
}
