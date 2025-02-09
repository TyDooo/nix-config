{pkgs, ...}: {
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd uwsm start -- hyprland.desktop";
        user = "tygo";
      };
    };
  };
}
