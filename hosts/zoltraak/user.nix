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
      extraGroups = ["networkmanager" "wheel" "users" "podman"];
      shell = pkgs.zsh;
      hashedPasswordFile = config.sops.secrets."users/tygo/password".path;
      openssh.authorizedKeys.keys = [(builtins.readFile ../ssh.pub)];
    };
  };

  home-manager.users.tygo = import ../../homes/tygo/${config.networking.hostName}.nix;

  sops.secrets."users/tygo/password" = {
    sopsFile = ../secrets.yaml;
    neededForUsers = true;
  };
}
