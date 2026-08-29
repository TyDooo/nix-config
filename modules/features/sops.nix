# NOTE: SOPS is handled by clan internally
{
  flake.nixosModules.base =
    { config, lib, ... }:
    let
      # SOPS needs access to the key before the persist dirs are even mounted; so
      # just persisting the key won't work, we must point at /persist
      hasOptinPersistence = config.environment ? persistence."/persist";

      sopsKeyDir = "${lib.optionalString hasOptinPersistence "/persist"}/var/lib/sops-nix";
    in
    {
      # Needed for sops-nix to decrypt the host key when using clan
      sops.age.keyFile = "${sopsKeyDir}/key.txt";

      # Make clan upload the key file directly to the location under /persist if
      # impermanence is enabled. This ensures that the correct key file is used
      # during the first boot of a new system.
      clan.core.vars.sops.secretUploadDirectory = sopsKeyDir;
    };
}
