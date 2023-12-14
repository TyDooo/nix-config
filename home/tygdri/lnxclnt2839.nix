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

    # Work monitors
    {
      desc = "Lenovo Group Limited LEN T27q-20 VNA79LMV";
      width = 2560;
      height = 1440;
      x = 3360;
    }
    {
      desc = "Lenovo Group Limited LEN T27q-20 VNA79LN4";
      width = 2560;
      height = 1440;
      transform = 1; # rotate 90deg
      x = 1920;
    }
  ];
}
