{
  flake.nixosModules.base =
    { self, pkgs, ... }:
    {
      _module.args.grimoire-utils = import ../../utils { inherit pkgs; };

      time.timeZone = "Europe/Amsterdam";

      # Manage `system.stateVersion` through clan vars
      clan.core.settings.state-version.enable = true;

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
          jj-wrapped
        ]);
    };
}
