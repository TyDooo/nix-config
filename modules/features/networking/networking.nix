{
  flake.nixosModules.base =
    { config, lib, ... }:
    let
      inherit (lib) mkForce mkDefault;
    in
    {
      networking = {
        # generate a unique hostname by hashing the hostname
        # with md5 and taking the first 8 characters of the hash
        hostId = builtins.substring 0 8 (builtins.hashString "md5" config.networking.hostName);

        # Force the use of networkd
        useDHCP = mkForce false;
        useNetworkd = mkForce true;

        # Enable firewall
        firewall.enable = true;

        # Already enabled by default, set just in case
        usePredictableInterfaceNames = mkDefault true;
      };
    };
}
