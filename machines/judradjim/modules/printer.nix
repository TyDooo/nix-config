{ pkgs, ... }: {
  services.printing = {
    enable = true;
    drivers = [
      pkgs.hplip
    ];
  };

  environment.systemPackages = [
    pkgs.hplip
  ];

  users.users.tydooo.extraGroups = [
    "lp"
    "lpadmin"
  ];
}
