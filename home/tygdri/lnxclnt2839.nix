{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ../common/global.nix

    ../common/desktop
    ../common/programs

    inputs.spicetify-nix.homeManagerModule
  ];

  home.username = "tygdri";

  home.packages = with pkgs; [
    thunderbird
    teams-for-linux
    microcom
    gnome.gnome-calculator
    speedcrunch
    openconnect
    sf100linux
  ];

  monitors = [
    {
      name = "eDP-1";
      width = 1920;
      height = 1080;
      primary = true;
    }
  ];
}
