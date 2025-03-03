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
  ];

  home-manager = {
    useGlobalPkgs = false;
    extraSpecialArgs = {inherit inputs outputs;};
    backupFileExtension = "hm.old";
  };
}
