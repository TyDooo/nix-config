{ pkgs, ... }: {
  hardware.sane = {
    enable = true;
    extraBackends = [
      pkgs.hplip
    ];
  };

  environment.systemPackages = [
    pkgs.simple-scan
  ];

  users.users.tydooo.extraGroups = [
    "scanner"
  ];
}
