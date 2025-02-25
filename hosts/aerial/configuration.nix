{
  outputs,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./nvidia.nix
    ./pipewire.nix
    ./hyprland.nix
    ./greet.nix
    ./fonts.nix
    ./boot.nix
    ./impermanence.nix
    ./user.nix

    ./hardware-configuration.nix
  ];

  networking = {
    hostName = "aerial";
    networkmanager.enable = true;

    # Spotify track sync with other devices
    firewall.allowedTCPPorts = [57621];
  };

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  nixpkgs.config.allowUnfree = true;

  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
    };
    gamescope.enable = true;
    firefox.enable = true;
    wireshark.enable = true;
    zsh.enable = true;
  };

  services.printing.enable = true;
  services.fwupd.enable = true;

  hardware.opentabletdriver.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    kitty
    helix
    git
    hyprpanel # TODO: move to home manager
    outputs.packages.${pkgs.system}.nvim # TODO: should be a better way to do this
  ];

  programs.thunar = {
    enable = true;
    plugins = [
      pkgs.xfce.thunar-archive-plugin
      pkgs.xfce.tumbler
    ];
  };

  services.flatpak.enable = true;

  virtualisation.virtualbox.host = {
    enable = true;
    enableExtensionPack = true;
    enableHardening = true;
  };

  nix = {
    settings = {
      auto-optimise-store = true;
      builders-use-substitutes = true;
      experimental-features = "nix-command flakes";

      trusted-users = ["root" "@wheel"];
    };
  };

  sops.secrets."users/tygo/smb-creds".sopsFile = ../secrets.yaml;

  fileSystems = let
    commonOptions = [
      "credentials=${config.sops.secrets."users/tygo/smb-creds".path}"
      "x-systemd.automount"
      "uid=1000"
      "gid=100"
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

    "/mnt/sauce" = {
      device = "//192.168.50.20/sauce";
      fsType = "cifs";
      options = commonOptions;
    };
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
