{inputs, ...}: {
  imports = [inputs.impermanence.nixosModules.impermanence];

  environment.persistence = {
    "/persist" = {
      files = [
        # important state
        "/etc/machine-id"

        # SSH stuff
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_ed25519_key.pub"
        "/etc/ssh/ssh_host_rsa_key"
        "/etc/ssh/ssh_host_rsa_key.pub"
      ];
      directories = [
        "/var/lib/systemd"
        "/var/lib/nixos"
        "/var/db/sudo"
      ];
    };
  };
  programs.fuse.userAllowOther = true;
}
