{
  config,
  pkgs,
  ...
}: {
  users = {
    mutableUsers = false;
    users.tygo = {
      description = "Tygo Driessen";
      isNormalUser = true;
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
      ];
      shell = pkgs.zsh;

      openssh.authorizedKeys.keys = [(builtins.readFile ./ssh.pub)];
      hashedPasswordFile = config.sops.secrets."users/tygo/password".path;
    };
  };

  home-manager.users.tygo = import ../../homes/tygo/${config.networking.hostName}.nix;

  sops.secrets."users/tygo/password" = {
    sopsFile = ./secrets.yaml;
    neededForUsers = true;
  };
}
