{
  config,
  pkgs,
  ...
}:
{
  nix.settings.trusted-users = [ "tydooo" ];

  users = {
    mutableUsers = false;
    users.tydooo = {
      isNormalUser = true;
      shell = pkgs.fish;
      uid = 1000;

      extraGroups = [
        "wheel"
        "systemd-journal"
        "audio"
        "video"
        "input"
        "dialout"
        "plugdev"
        "networkmanager"
        "users"
        "podman"
        "git"
        "libvirtd"
        "media"
        "tss"
      ];
      group = "tydooo";
    };
    groups.tydooo.gid = 1000;
  };

  home-manager.users.tydooo = import ./home/${config.networking.hostName}.nix;

  # Make sure fish is enabled, as it is the default shell for the user
  programs.fish.enable = true;
}
