{ pkgs, inputs, ... }:

let
  inherit (pkgs.vimUtils) buildVimPlugin;
  inherit (pkgs) fetchFromGitHub;

  inherit (builtins) attrValues;

  inherit (pkgs.vimPlugins) nvim-treesitter;
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
      lsp-zero-nvim
      lspkind-nvim
      nvim-web-devicons

      mini-nvim
      nvim-notify
      gitsigns-nvim
      vim-fugitive
      oil-nvim
      nvim-surround
      telescope-nvim
      neoformat
      nvim-highlight-colors
      noice-nvim
      nui-nvim
      undotree
      ;

      treesitter = nvim-treesitter.withPlugins (p: with p; [
        tree-sitter-lua
        tree-sitter-python
        tree-sitter-bash
        tree-sitter-vim
        tree-sitter-vimdoc
        tree-sitter-css
        tree-sitter-html
        tree-sitter-nix
        tree-sitter-markdown
        tree-sitter-go
      ]);

      vim-moonfly-colors = buildVimPlugin {
        pname = "vim-moonfly-colors";
        version = "master";
        src = fetchFromGitHub {
          owner = "bluz71";
          repo = "vim-moonfly-colors";
          rev = "261664f92ed51cf0c077555b2d4b2530307eac17";
          hash = "sha256-g7Tjm3a1aAbEQocSK1iDRamXivq1AwWlD6Q0X6vphNU=";
        };
      };

      # kerboscript-vim = buildVimPlugin {
      #   pname = "kerboscript-vim";
      #   version = "master";
      #   src = fetchFromGitHub {
      #     owner = "KSP-KOS";
      #     repo = "EditorTools";
      #     rev = "develop";
      #     hash = "sha256-F2U8QgkMoUyQVifUFKmAO1TT8chAIh0GWkHgCsSqU4A=";
      #   };
      # };

      config = buildVimPlugin {
        pname = "nvim-config";
        version = "#";
        src = ./.;
      };
    };

    extraPackages = attrValues {
      inherit (pkgs) lua-language-server gopls;
      inherit (pkgs.python311Packages) python-lsp-server;
      inherit (inputs.nil.packages.x86_64-linux) nil;
    };
  };
}
