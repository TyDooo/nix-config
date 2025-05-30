{
  lib,
  self,
  inputs,
  withSystem,
  ...
}: let
  inherit (self) outputs;
  inherit (lib.lists) singleton concatLists;

  mkHost = {
    hostname,
    system,
    ...
  } @ args:
    withSystem system (
      {self', ...}:
        inputs.nixpkgs.lib.nixosSystem {
          specialArgs = {inherit inputs outputs self';};
          modules = concatLists [
            (singleton {
              networking.hostName = hostname;
              nixpkgs.hostPlatform = lib.mkDefault system;
            })

            [
              ./common/global
              ../users/tygo/user.nix

              (./. + "/${hostname}/host.nix")
              (./. + "/${hostname}/disko.nix")
              (./. + "/${hostname}/hardware.nix")

              inputs.home-manager.nixosModules.home-manager
              inputs.disko.nixosModules.default
            ]

            # Optinally allow per host modules
            (args.modules or [])
          ];
        }
    );
in {
  flake.nixosConfigurations = {
    catastravia = mkHost {
      hostname = "catastravia";
      system = "x86_64-linux";
    };

    zoltraak = mkHost {
      hostname = "zoltraak";
      system = "x86_64-linux";
    };
  };
}
