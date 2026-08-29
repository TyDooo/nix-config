{
  flake.nixosModules.base = {
    # Passwordless sudo when SSH'ing with keys
    security.pam.sshAgentAuth.enable = true;
  };
}
