{inputs, ...}: {
  imports = [inputs.devshell.flakeModule];
  perSystem = {
    inputs',
    config,
    self',
    pkgs,
    ...
  }: {
    devshells.default = {
      env = [
        {
          name = "DIRENV_LOG_FORMAT";
          value = "";
        }
      ];

      commands = [
        {
          name = "switch";
          command = "nixos-rebuild switch --flake . --sudo";
        }
        {
          name = "boot";
          command = "nixos-rebuild boot --flake . --sudo";
        }
      ];

      packages = [
        config.treefmt.build.wrapper

        inputs'.deploy-rs.packages.default

        self'.packages.nvim

        pkgs.alejandra
        pkgs.nixos-anywhere

        pkgs.git # Required to use flakes

        # Secrets related stuff
        pkgs.sops
        pkgs.ssh-to-age
        pkgs.gnupg
        pkgs.age
      ];
    };
  };
}
