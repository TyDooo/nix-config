{ inputs, self, ... }: {
  flake.nixosModules.niri = { pkgs, ... }: {
    programs.niri = {
      enable = true;
      package = self.packages.${pkgs.stdenv.hostPlatform.system}.myNiri;
    };

    # TODO: move these
    services.gnome.gnome-keyring.enable = true;
    services.udisks2.enable = true; # Removable media.
    services.gvfs.enable = true; # Nautilus mount and trash support.

    environment.systemPackages = with pkgs; [
      # TODO: Move these
      loupe # GNOME image viewer
      papers # GNOME document viewer
      nautilus # GNOME file manager

      # Niri deps from their docs
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
    ];
  };

  perSystem =
    {
      self',
      pkgs,
      lib,
      ...
    }:
    let
      # 0WD0's niri fork (wd/vertical-layout branch) - adds two-dimensional
      # layouting so niri works on vertical monitors.
      niriFork = pkgs.niri.overrideAttrs (_oldAttrs: rec {
        version = "unstable-fork-2026-06-19";

        src = pkgs.fetchFromGitHub {
          owner = "0WD0";
          repo = "niri";
          rev = "803cf8e53e11d7d9237dc75e6701fcc8863fc1da";
          hash = "sha256-gvoq9a81pprMRsmREcUJ0X0zTgLm9AVMhkTUoxl4NqE=";
        };

        cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
          inherit src;
          name = "niri-unstable-fork-2026-08-03";
          hash = "sha256-HypBB3PL4nVFMNH2+jEK0+dG9dJ920nHi8GwRoeH/v4=";
        };

        # The fork's Cargo.toml version probably won't match `version` above,
        # so skip the version-string sanity check.
        doInstallCheck = false;
      });
    in
    {
      packages.myNiri = inputs.wrapper-modules.wrappers.niri.wrap {
        inherit pkgs;

        package = niriFork;

        # TODO: convert config.kdl to nix
        settings = {
          spawn-at-startup = [
            (lib.getExe self'.packages.myNoctalia)
          ];

          xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;

          binds = {
            "Mod+T" = _: {
              props.hotkey-overlay-title = "Open a Terminal: kitty";
              content.spawn = lib.getExe self'.packages.myKitty;
            };
            "Mod+Space" = _: {
              props.hotkey-overlay-title = "Open Noctalia launcher";
              content.spawn-sh = "${lib.getExe self'.packages.myNoctalia} ipc call launcher toggle";
            };
            "Super+Alt+L" = _: {
              props.hotkey-overlay-title = "Lock screen";
              content.spawn-sh = "${lib.getExe self'.packages.myNoctalia} ipc call sessionMenu lock";
            };

            "XF86MonBrightnessUp" = _: {
              props.allow-when-locked = true;
              content.spawn = [
                (lib.getExe pkgs.brightnessctl)
                "--class=backlight"
                "set"
                "+10%"
              ];
            };
            "XF86MonBrightnessDown" = _: {
              props.allow-when-locked = true;
              content.spawn = [
                (lib.getExe pkgs.brightnessctl)
                "--class=backlight"
                "set"
                "10%-"
              ];
            };
          };
        };

        extraSettings = [
          { include = ./config.kdl; }
          {
            include = [
              { optional = true; }
              "~/.config/niri/noctalia.kdl"
            ];
          }
        ];
      };
    };
}
