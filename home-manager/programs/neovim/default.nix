{ pkgs, inputs, ... }:

let
  inherit (pkgs.vimUtils) buildVimPlugin;
  inherit (pkgs) fetchFromGitHub;

  inherit (builtins) attrValues;

  inherit (pkgs.vimPlugins) nvim-treesitter;

  treesitterParsers = pkgs.symlinkJoin {
    name = "treesitter-parsers";
    paths = (nvim-treesitter.withPlugins (p: with p; [
      lua
      nix
      python
      bash
      vim
      vimdoc
      css
      html
      markdown
      regex
    ])).dependencies;
  };
in
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    withRuby = false;
    withPython3 = false;
    withNodeJs = false;

    sideloadInitLua = true;

    plugins = attrValues {
      inherit (pkgs.vimPlugins)
      # Completion
      nvim-cmp
      cmp-nvim-lua
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      cmp-cmdline

      # Snippets
      luasnip
      cmp_luasnip
      friendly-snippets

      # LSP
      nvim-lspconfig
      lspkind-nvim
      nvim-web-devicons

      mini-nvim
      nvim-notify
      gitsigns-nvim
      vim-fugitive
      oil-nvim
      nvim-surround
      telescope-nvim
      nvim-highlight-colors
      noice-nvim
      nui-nvim
      nvim-treesitter

      vim-moonfly-colors
      ;
    };

    extraPackages = attrValues {
      inherit (pkgs) lua-language-server gopls tree-sitter nil ruff;
      inherit (pkgs.python3Packages) python-lsp-server;
      inherit (pkgs.kdePackages) qtdeclarative; # provides qml lsp
    };

    # qmlls only reads QML_IMPORT_PATH (-E), not the Nix Qt wrapper variable.
    extraWrapperArgs = [
      "--prefix"
      "QML_IMPORT_PATH"
      ":"
      (pkgs.lib.makeSearchPath "lib/qt-6/qml" [
        pkgs.kdePackages.qtdeclarative
        pkgs.quickshell
      ])
    ];
  };

  home.file.".config/nvim" = {
    source = ./.;
    recursive = true;
  };

  # clanker said this was right idfk
  home.file.".config/nvim/parser".source = "${treesitterParsers}/parser";

  home.file.".config/nvim/queries" = {
    source = "${pkgs.vimPlugins.nvim-treesitter}/runtime/queries";
    recursive = true;
  };
}
