{
  flake.nixosModules.qmk = { pkgs, ... }: {
    hardware.keyboard.qmk.enable = true;
    users.users.tydooo.extraGroups = [ "plugdev" ];
    environment.systemPackages = with pkgs; [
      qmk
      vial
    ];
  };
}
