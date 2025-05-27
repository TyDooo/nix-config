{lib, ...}: {
  imports = [
    ./programs
  ];

  nixpkgs = {
    config = {
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      # TODO: Check if still needed.
      allowUnfreePredicate = _: true;
    };
  };

  home = {
    username = "tygo";
    homeDirectory = "/home/tygo";
  };

  programs.home-manager.enable = true;
  news.display = "silent";

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = lib.mkDefault "24.11";
}
