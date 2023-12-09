{
  inputs,
  outputs,
  ...
}: {
  imports = [
    ../common/global.nix

    ../common/desktop
    ../common/programs

    inputs.spicetify-nix.homeManagerModule
  ];

  wallpaper = outputs.wallpapers.dark;

  monitors = [
    {
      name = "DP-1";
      width = 3440;
      height = 1440;
      refreshRate = 120;
      primary = true;
    }
  ];
}
