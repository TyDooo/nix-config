{ pkgs, ... }: {
  services.pcscd.enable = true;

  environment.systemPackages = with pkgs; [
    age-plugin-yubikey
  ];
}
