{ inputs, outputs, ... }: {
  flake.nixosModules.base =
    { inputs', ... }:
    {
      imports = [ inputs.home-manager.nixosModules.home-manager ];

      home-manager = {
        useGlobalPkgs = false;
        extraSpecialArgs = { inherit inputs outputs inputs'; };
        backupFileExtension = "hm.old";
      };
    };
}
