{
  inputs,
  outputs,
  ...
}: {
  imports = [
    ./impermanence.nix
    ./openssh.nix
    ./podman.nix
    ./sops.nix
    ./nix.nix
  ];

  time.timeZone = "Europe/Amsterdam";

  i18n.defaultLocale = "en_US.UTF-8";

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

  home-manager = {
    useGlobalPkgs = false;
    extraSpecialArgs = {inherit inputs outputs;};
    backupFileExtension = "hm.old";
  };
}
