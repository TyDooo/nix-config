{ inputs, ... }:
{
  imports = [ inputs.impermanence.nixosModules.impermanence ];

  environment.persistence = {
    "/persist" = {
      files = [
        # important state
        "/etc/machine-id"
      ];
      directories = [
        "/var/lib/systemd"
        "/var/lib/nixos"
        "/var/db/sudo"

        # Needed for sops-nix to decrypt the host key when using clan
        "/var/lib/sops-nix"

        "/var/lib/containers"
        "/var/lib/zerotier-one"
        {
          directory = "/var/lib/data-mesher";
          user = "data-mesher";
          group = "data-mesher";
          mode = "0755";
        }
        {
          directory = "/var/lib/unbound";
          user = "unbound";
          group = "unbound";
          mode = "0755";
        }
      ];
    };
  };
  programs.fuse.userAllowOther = true;
}
