{inputs, ...}: {
  imports = [inputs.impermanence.nixosModules.impermanence];

  environment.persistence = {
    "/persist" = {
      files = [
        "/etc/machine-id"
      ];
      directories = [
        "/var/lib/systemd"
        "/var/lib/nixos"
      ];
    };
  };
  programs.fuse.userAllowOther = true;
}
