{
  inputs,
  self,
  ...
}: {
  flake.deploy = {
    nodes = {
      zoltraak = {
        hostname = "zoltraak";
        profiles.system = {
          sshUser = "tygo";
          user = "root";
          remoteBuild = true;
          path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.zoltraak;
          interactiveSudo = true;
        };
      };
    };
  };
}
