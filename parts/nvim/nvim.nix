{
  config.vim = {
    viAlias = true;
    vimAlias = true;

    options = {
      tabstop = 2;
      shiftwidth = 2;
      expandtab = true;
    };

    lsp = {
      formatOnSave = true;
      lspkind.enable = false;
      lightbulb.enable = true;
      lspsaga.enable = false;
      trouble.enable = true;
      lspSignature.enable = true;
      otter-nvim.enable = true;
      nvim-docs-view.enable = true;
    };

    debugger = {
      nvim-dap = {
        enable = true;
        ui.enable = true;
      };
    };

    languages = {
      enableFormat = true;
      enableTreesitter = true;
      enableExtraDiagnostics = true;

      nix.enable = true; # FIXME: nix treesitter messes with the newline indentation
      markdown.enable = true;
      bash.enable = true;
      clang.enable = true;
      css.enable = true;
      html.enable = true;
      ts.enable = true;
      go.enable = true;
      tailwind.enable = true;
      svelte.enable = true;
    };

    lsp.enable = true;

    visuals = {
      nvim-scrollbar.enable = true;
      nvim-web-devicons.enable = true;
      nvim-cursorline.enable = true;
      cinnamon-nvim.enable = true;

      highlight-undo.enable = true;
      indent-blankline.enable = true;
    };

    statusline.lualine.enable = true;

    theme = {
      enable = true;
      name = "tokyonight";
      style = "night";
      transparent = true;
    };

    autopairs.nvim-autopairs.enable = true;
    autocomplete.nvim-cmp.enable = true;
    snippets.luasnip.enable = true;
    filetree.neo-tree.enable = true;
    tabline.nvimBufferline.enable = true;
    treesitter.context.enable = true;

    binds = {
      whichKey.enable = true;
      cheatsheet.enable = true;
    };

    telescope.enable = true;

    git = {
      enable = true;
      gitsigns.enable = true;
      gitsigns.codeActions.enable = false; # throws an annoying debug message
    };

    dashboard.alpha.enable = true;

    utility = {
      ccc.enable = false;
      vim-wakatime.enable = false;
      icon-picker.enable = true;
      surround.enable = true;
      diffview-nvim.enable = true;
      yanky-nvim.enable = false;
      motion = {
        hop.enable = true;
        leap.enable = true;
        precognition.enable = true;
      };

      images.image-nvim.enable = false;
    };

    notes = {
      mind-nvim.enable = true;
      todo-comments.enable = true;
    };

    terminal = {
      toggleterm = {
        enable = true;
        lazygit.enable = true;
      };
    };

    ui = {
      borders.enable = true;
      noice.enable = true;
      colorizer.enable = true;
      illuminate.enable = true;
      breadcrumbs = {
        enable = true;
        navbuddy.enable = true;
      };
      smartcolumn = {
        enable = true;
        setupOpts.custom_colorcolumn = {
          # this is a freeform module, it's `buftype = int;` for configuring column position
          nix = "110";
          go = ["90" "130"];
        };
      };
      fastaction.enable = true;
    };

    notify.nvim-notify.enable = true;
    projects.project-nvim.enable = true;
    gestures.gesture-nvim.enable = false;
    comments.comment-nvim.enable = true;
    presence.neocord.enable = false;
  };
}
