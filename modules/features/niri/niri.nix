{ inputs, self, ... }: {
  flake.nixosModules.niri = { pkgs, ... }: {
    programs.niri = {
      enable = true;
      package = self.packages.${pkgs.stdenv.hostPlatform.system}.niri-wrapped;
    };

    # TODO: move these
    services.gnome.gnome-keyring.enable = true;
    services.udisks2.enable = true; # Removable media.
    services.gvfs.enable = true; # Nautilus mount and trash support.

    environment.systemPackages = with pkgs; [
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

      verticalOutputs = [
        "HDMI-A-2"
      ];

      niri-directional = pkgs.writeShellApplication {
        name = "niri-directional";

        runtimeInputs = [
          niriFork
          pkgs.jq
        ];

        text = ''
          export NIRI_VERTICAL_OUTPUTS=${lib.escapeShellArg (lib.concatStringsSep ":" verticalOutputs)}

          ${builtins.readFile ./niri-directional.sh}
        '';
      };

      mkMoveBinding = direction: "${lib.getExe niri-directional} move ${direction}";
      mkFocusBinding = direction: "${lib.getExe niri-directional} focus ${direction}";
      mkMoveMonitorBinding = direction: "${lib.getExe niri-directional} move-monitor ${direction}";
      mkFocusMonitorBinding = direction: "${lib.getExe niri-directional} focus-monitor ${direction}";

      empty = _: { };
    in
    {
      packages.niri-wrapped = inputs.wrapper-modules.wrappers.niri.wrap {
        inherit pkgs;

        package = niriFork;

        # TODO: convert config.kdl to nix
        settings = {
          spawn-at-startup = [
            (lib.getExe self'.packages.myNoctalia)
          ];

          prefer-no-csd = empty;

          xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;

          outputs = {
            "DP-1" = {
              mode = "3440x1440@120.000";
              scale = 1;
              transform = "normal";
              position = _: {
                props.x = 1080;
                props.y = 310;
              };
              focus-at-startup = empty;
            };

            "HDMI-A-2" = {
              mode = "1920x1080@119.997";
              scale = 1;
              transform = "90";
              position = _: {
                props.x = 0;
                props.y = 0;
              };

              # NOTE: this is part of 0WD0's Niri fork
              layout.main-axis = "vertical";
            };
          };

          binds = {
            "Mod+T".spawn = lib.getExe self'.packages.kitty-wrapped;

            "Mod+Q" = _: {
              props.repeat = false;
              content.close-window = empty;
            };

            "Mod+F".maximize-column = empty;
            "Mod+Shift+F".fullscreen-window = empty;

            "Mod+C".center-column = empty;

            "Mod+Minus".set-column-width = "-5%";
            "Mod+Equal".set-column-width = "+5%";

            "Mod+Shift+Minus".set-window-height = "-5%";
            "Mod+Shift+Equal".set-window-height = "+5%";

            "Mod+Left".spawn-sh = mkFocusBinding "left";
            "Mod+Down".spawn-sh = mkFocusBinding "down";
            "Mod+Up".spawn-sh = mkFocusBinding "up";
            "Mod+Right".spawn-sh = mkFocusBinding "right";
            "Mod+H".spawn-sh = mkFocusBinding "left";
            "Mod+J".spawn-sh = mkFocusBinding "down";
            "Mod+K".spawn-sh = mkFocusBinding "up";
            "Mod+L".spawn-sh = mkFocusBinding "right";

            "Mod+Ctrl+Left".spawn-sh = mkMoveBinding "left";
            "Mod+Ctrl+Down".spawn-sh = mkMoveBinding "down";
            "Mod+Ctrl+Up".spawn-sh = mkMoveBinding "up";
            "Mod+Ctrl+Right".spawn-sh = mkMoveBinding "right";
            "Mod+Ctrl+H".spawn-sh = mkMoveBinding "left";
            "Mod+Ctrl+J".spawn-sh = mkMoveBinding "down";
            "Mod+Ctrl+K".spawn-sh = mkMoveBinding "up";
            "Mod+Ctrl+L".spawn-sh = mkMoveBinding "right";

            "Mod+Shift+Left".spawn-sh = mkFocusMonitorBinding "left";
            "Mod+Shift+Down".spawn-sh = mkFocusMonitorBinding "down";
            "Mod+Shift+Up".spawn-sh = mkFocusMonitorBinding "up";
            "Mod+Shift+Right".spawn-sh = mkFocusMonitorBinding "right";
            "Mod+Shift+H".spawn-sh = mkFocusMonitorBinding "left";
            "Mod+Shift+J".spawn-sh = mkFocusMonitorBinding "down";
            "Mod+Shift+K".spawn-sh = mkFocusMonitorBinding "up";
            "Mod+Shift+L".spawn-sh = mkFocusMonitorBinding "right";

            "Mod+Shift+Ctrl+Left".spawn-sh = mkMoveMonitorBinding "left";
            "Mod+Shift+Ctrl+Down".spawn-sh = mkMoveMonitorBinding "down";
            "Mod+Shift+Ctrl+Up".spawn-sh = mkMoveMonitorBinding "up";
            "Mod+Shift+Ctrl+Right".spawn-sh = mkMoveMonitorBinding "right";
            "Mod+Shift+Ctrl+H".spawn-sh = mkMoveMonitorBinding "left";
            "Mod+Shift+Ctrl+J".spawn-sh = mkMoveMonitorBinding "down";
            "Mod+Shift+Ctrl+K".spawn-sh = mkMoveMonitorBinding "up";
            "Mod+Shift+Ctrl+L".spawn-sh = mkMoveMonitorBinding "right";

            "Mod+1".focus-workspace = 1;
            "Mod+2".focus-workspace = 2;
            "Mod+3".focus-workspace = 3;
            "Mod+4".focus-workspace = 4;
            "Mod+5".focus-workspace = 5;
            "Mod+6".focus-workspace = 6;
            "Mod+7".focus-workspace = 7;
            "Mod+8".focus-workspace = 8;
            "Mod+9".focus-workspace = 9;

            "Mod+Ctrl+1".move-column-to-workspace = 1;
            "Mod+Ctrl+2".move-column-to-workspace = 2;
            "Mod+Ctrl+3".move-column-to-workspace = 3;
            "Mod+Ctrl+4".move-column-to-workspace = 4;
            "Mod+Ctrl+5".move-column-to-workspace = 5;
            "Mod+Ctrl+6".move-column-to-workspace = 6;
            "Mod+Ctrl+7".move-column-to-workspace = 7;
            "Mod+Ctrl+8".move-column-to-workspace = 8;
            "Mod+Ctrl+9".move-column-to-workspace = 9;

            "Mod+Space".spawn-sh = "${lib.getExe self'.packages.myNoctalia} ipc call launcher toggle";
            "Super+Alt+L".spawn-sh = "${lib.getExe self'.packages.myNoctalia} ipc call sessionMenu lock";

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
                "-10%"
              ];
            };

            "Print".screenshot = empty;
            "Ctrl+Print".screenshot-screen = empty;
            "Alt+Print".screenshot-window = empty;
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
