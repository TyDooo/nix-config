{
  inputs',
  inputs,
  outputs,
  self,
  pkgs,
  ...
}:
{
  imports = [
    ./networking

    ./podman.nix
    ./sops.nix
    ./nix.nix
  ];

  _module.args.grimoire-utils = import ../../utils { inherit pkgs; };

  time.timeZone = "Europe/Amsterdam";

  i18n.defaultLocale = "en_US.UTF-8";

  # Manage `system.stateVersion` through clan vars
  clan.core.settings.state-version.enable = true;

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "nl_NL.UTF-8";
    LC_IDENTIFICATION = "nl_NL.UTF-8";
    LC_MEASUREMENT = "nl_NL.UTF-8";
    LC_MONETARY = "nl_NL.UTF-8";
    LC_NAME = "nl_NL.UTF-8";
    LC_NUMERIC = "nl_NL.UTF-8";
    LC_PAPER = "nl_NL.UTF-8";
    LC_TELEPHONE = "nl_NL.UTF-8";
    LC_TIME = "nl_NL.UTF-8";
  };

  users.groups = {
    # The media group has access to the media directory on zoltraak, both
    # on the machine itself and over NFS.
    media.gid = 990;
  };

  environment.systemPackages =
    with pkgs;
    [
      git
      vim
      wget
      fastfetch
      fd
    ]
    ++ (with self.packages.${pkgs.stdenv.hostPlatform.system}; [
      helix-wrapped
      btop-wrapped
    ]);

  home-manager = {
    useGlobalPkgs = false;
    extraSpecialArgs = { inherit inputs outputs inputs'; };
    backupFileExtension = "hm.old";
  };
}
