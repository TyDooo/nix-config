{
  inputs,
  self,
  ...
}: {
  flake.deploy = {
    autoRollback = true;
    magicRollback = true;
    nodes = {
      zoltraak = {
        hostname = "zoltraak";

        profilesOrder = ["system"];
        profiles.system = {
          sshUser = "tygo";
          user = "root";
          remoteBuild = true;
          path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.zoltraak;
          interactiveSudo = true;
        };
      };

      catastravia = {
        hostname = "catastravia";

        profilesOrder = ["system"];
        profiles.system = {
          sshUser = "tygo";
          user = "root";
          remoteBuild = true;
          path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.catastravia;
          interactiveSudo = true;
        };
      };
    };
  };
}
