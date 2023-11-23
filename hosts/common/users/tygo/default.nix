{ pkgs, config, ... }:

{
  users.users.tygo = {
    isNormalUser = true;
    description = "Tygo Driessen";
    extraGroups = [ "networkmanager" "wheel" ];

    openssh.authorizedKeys.keys =
      [ (builtins.readFile ../../../../home/ssh.pub) ];
    hashedPasswordFile = config.sops.secrets.tygo-password.path;
    packages = [ pkgs.home-manager ];
  };

  sops.secrets.tygo-password = {
    sopsFile = ../../secrets.yaml;
    neededForUsers = true;
  };

  security.pam.services.swaylock.text = "auth include login";
}
