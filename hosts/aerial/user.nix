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
    };
  };

  sops.secrets."users/tygo/password" = {
    sopsFile = ../secrets.yaml;
    neededForUsers = true;
  };
}
