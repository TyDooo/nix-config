{
  config,
  pkgs,
  ...
}: {
  nix.settings.trusted-users = ["tygo"];

  users = {
    mutableUsers = false;
    users.tygo = {
      description = "Tygo Driessen";
      isNormalUser = true;
      shell = pkgs.zsh;
      uid = 1000;

      extraGroups = [
        "wheel"
        "systemd-journal"
        "audio"
        "video"
        "input"
        "plugdev"
        "networkmanager"
        "users"
        "podman"
        "git"
        "libvirtd"
        "shared"
      ];
      group = "tygo";

      openssh.authorizedKeys.keys = [(builtins.readFile ./ssh.pub)];
      hashedPasswordFile = config.sops.secrets."users/tygo/password".path;
    };
    groups.tygo.gid = 1000;
  };

  home-manager.users.tygo = import ../../homes/tygo/${config.networking.hostName}.nix;

  sops.secrets."users/tygo/password" = {
    sopsFile = ./secrets.yaml;
    neededForUsers = true;
  };

  # Make sure zsh is enable, as it is the default shell for the user
  programs.zsh.enable = true;
}
