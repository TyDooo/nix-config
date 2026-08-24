{ self, ... }: {
  flake.nixosModules.desktop = { pkgs, ... }: {
    imports = [
      self.nixosModules.niri
      self.nixosModules.greetd
    ];

    environment.systemPackages = with pkgs; [
      loupe # GNOME image viewer
      papers # GNOME document viewer
      nautilus # GNOME file manager
    ];
  };
}
