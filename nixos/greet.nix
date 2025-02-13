{pkgs, ...}: {
  users.extraUsers.greeter = {
    # For caching and such
    home = "/tmp/greeter-home";
    createHome = true;
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = ''
          ${pkgs.greetd.tuigreet}/bin/tuigreet \
          --time \
          --remember \
          --user-menu \
          --cmd "${pkgs.uwsm}/bin/uwsm start hyprland-uwsm.desktop"
        '';
        user = "greeter";
      };
    };
  };
}
