{ pkgs, ... }:
{
  home.packages = [
    pkgs.ctags
  ];

  programs.nixvim = {
    plugins = {
      notify = {
        enable = true;
        settings = {
          stages = "static";
          render.__raw =
            # lua
            ''"compact"'';
          icons = {
            debug = "";
            error = "󰅙";
            info = "";
            trace = "󰰥";
            warn = "";
          };
        };
      };

      # Commenting
      comment.enable = true;
      # Extend vim's "%" key
      vim-matchup.enable = true;

      # Fzf picker for arbitrary stuff
      telescope = {
        enable = true;
        enabledExtensions = [
          "fzf"
          "notify"
          "ui-select"
          "textcase"
        ];
        extensions.fzf-native.enable = true;
        settings.defaults.mappings.i."<esc>".__raw =
          # lua
          ''
            function(...)
              return require("telescope.actions").close(...)
            end
          '';
      };

      # Undo tree
      undotree = {
        enable = true;
        settings = {
          FocusOnToggle = true;
          WindowLayout = 4;
        };
      };

      # Quickfix menu
      trouble.enable = true;
      # Highlight certain keywords
      todo-comments.enable = true;
      # TODO use { "liuchengxu/vista.vim", cmd = "Vista" }
      which-key.enable = true;

      # filesystem in buffer
      oil.enable = true;

    };

    extraPlugins = with pkgs.vimPlugins; [
      telescope-ui-select-nvim
      nvim-window-picker
      # Replace built-in LSP prompts and windows
      dressing-nvim
      # Multicursor
      vim-visual-multi
      # Show invalid whitespace
      vim-better-whitespace
      # Show latex math equations
      nabla-nvim
      # Modify Surrounding things like parenthesis and quotes
      vim-sandwich
      # TODO mini.align better?
      vim-easy-align
      # Case changer
      text-case-nvim
      # camelcase (and similar) word motions and textobjects
      vim-wordmotion
      # Gpg integration
      vim-gnupg
      # TODO temporary
      vim-startuptime
      # flutter
      vim-flutter
      # Respect editor-config files
      editorconfig-nvim
      # Outline view
      vista-vim
      # better popups (i think)
      popup-nvim

      # TODO: flutter-tools-nvim | currently broken https://github.com/akinsho/flutter-tools.nvim/pull/259
    ];

    extraConfigLuaPre =
      # lua
      ''
        vim.g.operator_sandwich_no_default_key_mappings = 1
        vim.g.textobj_sandwich_no_default_key_mappings = 1

        vim.g.wordmotion_nomap = 1
      '';

    extraConfigLuaPost =
      # lua
      ''
        require("window-picker").setup {
          hint = "floating-big-letter",
          filter_rules = {
            bo = {
              filetype = { "neo-tree", "neo-tree-popup", "notify", "quickfix" },
              buftype = { "terminal", "quickfix", "prompt" },
            },
          },
          floating_big_letter = {
            font = "ansi-shadow",
          },
          selection_chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ",
          show_prompt = false,
        }

        require("dressing").setup {
          input = {
            prefer_width = 80,
            max_width = { 140, 0.9 },
            min_width = { 80, 0.6 },
            win_options = {
              winblend = 0,
            },
          },
        }

        require('textcase').setup {
          default_keymappings_enabled = false,
        }
      '';
  };
}
