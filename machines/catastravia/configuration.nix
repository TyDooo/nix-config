{ config, ... }: {
  imports = [
    ./services
  ];

  boot = {
    initrd.systemd.enable = true;
    loader.grub = {
      enable = true;
      devices = [ "/dev/sda" ];
      efiSupport = true;
    };
  };

  system.nuke = {
    root = true; # Remove the root directory on each boot
    home = false; # I'm not confident enough to nuke the home directory yet
  };

  environment.persistence = {
    "/persist".directories = [
      {
        directory = config.services.pocket-id.dataDir;
        inherit (config.services.pocket-id) user group;
      }
    ];
  };

  clan.core.state.pocket-id = {
    folders = [ config.services.pocket-id.dataDir ];
    preBackupScript = ''
      systemctl stop pocket-id.service
    '';
    postBackupScript = ''
      systemctl start pocket-id.service
    '';
  };
}
