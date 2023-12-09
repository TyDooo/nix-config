{inputs, ...}: {
  imports = [
    ../common/global.nix

    ../common/desktop
    ../common/programs

    inputs.spicetify-nix.homeManagerModule
  ];

  home.username = "tygdri";

  monitors = [
    {
      name = "eDP-1";
      width = 1920;
      height = 1920;
      primary = true;
    }
  ];
}
