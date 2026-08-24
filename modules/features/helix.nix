{ inputs, ... }: {
  perSystem = { pkgs, ... }: {
    packages.helix-wrapped = inputs.wrapper-modules.wrappers.helix.wrap {
      inherit pkgs;

      settings = {
        theme = "rose_pine";

        editor = {
          lsp.display-inlay-hints = true;
          cursorline = true;
          color-modes = true;
        };

        editor.indent-guides = {
          render = true;
        };
      };

      languages = {
        language = [
          {
            name = "nix";
            auto-format = true;
            formatter.command = "nixfmt";
          }
        ];
      };
    };
  };
}
