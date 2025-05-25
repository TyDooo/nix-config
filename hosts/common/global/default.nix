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

  home-manager = {
    useGlobalPkgs = false;
    extraSpecialArgs = {inherit inputs outputs;};
    backupFileExtension = "hm.old";
  };
}
