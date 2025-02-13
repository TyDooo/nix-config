{
  pkgs,
  outputs,
  ...
}: {
  imports = [
    ./nvidia.nix
    ./pipewire.nix
    ./hyprland.nix
    ./greet.nix
    ./fonts.nix
    ./boot.nix
    ./podman.nix

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

  nix.settings = {
    experimental-features = "nix-command flakes";
  };

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

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.tygo = {
    description = "Tygo Driessen";
    isNormalUser = true;
    extraGroups = ["networkmanager" "wheel"]; # Enable ‘sudo’ for the user.
    shell = pkgs.zsh;
  };

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
