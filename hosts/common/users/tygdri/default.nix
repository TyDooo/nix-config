{
  pkgs,
  config,
  ...
}: {
  users.mutableUsers = false;
  users.users.tygdri = {
    isNormalUser = true;
    description = "Tygo Driessen";
    extraGroups = ["networkmanager" "wheel"];

    openssh.authorizedKeys.keys = [(builtins.readFile home/ssh.pub)];
    hashedPasswordFile = config.sops.secrets.tygo-password.path;
    packages = [pkgs.home-manager];
  };

  sops.secrets.tygo-password = {
    sopsFile = ../../secrets.yaml;
    neededForUsers = true;
  };

  home-manager.users.tygdri = import home/tygdri/${config.networking.hostName}.nix;

  security.pam.services.swaylock.text = "auth include login";
}
