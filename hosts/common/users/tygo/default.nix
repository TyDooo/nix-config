{
  pkgs,
  config,
  ...
}: {
  users.mutableUsers = false;
  users.users.tygo = {
    isNormalUser = true;
    description = "Tygo Driessen";
    extraGroups = ["networkmanager" "wheel"];
    shell = pkgs.zsh;

    openssh.authorizedKeys.keys = [(builtins.readFile home/ssh.pub)];
    hashedPasswordFile = config.sops.secrets.tygo-password.path;
    packages = [pkgs.home-manager];
  };

  sops.secrets.tygo-password = {
    sopsFile = ../../secrets.yaml;
    neededForUsers = true;
  };

  home-manager.users.tygo = import home/tygo/${config.networking.hostName}.nix;

  security.pam.services.swaylock.text = "auth include login";
}
