{
  programs.nixvim = {
    plugins = {
      #luasnip = {
      #  enable = true;
      #  settings = {
      #    history = true;
      #    # Update dynamic snippets while typing
      #    updateevents = "TextChanged,TextChangedI";
      #    enable_autosnippets = true;
      #  };
      #};

      copilot-lua = {
        enable = true;
        settings = {
          filetypes = {
            markdown = true;
            sh.__raw = ''
              function ()
                if string.match(vim.fs.basename(vim.api.nvim_buf_get_name(0)), '^%.env.*') then
                  -- disable for .env files
                  return false
                end
                return true
              end
            '';
          };
          # TODO: override server to get more completions
          suggestion.enabled = false;
          panel.enabled = false;
        };
      };
      #copilot-cmp.enable = true;
      #copilot-chat.enable = true;

      avante = {
        enable = true;
        settings = {
          provider = "copilot";
          auto_suggestions_frequency = "copilot";
          provides = {
            copilot = {
              #model = "claude-3.7-sonnet";
              model = "claude-4-sonnet";
              #model = "gemini-2.5-pro";
              #model = "gpt-4.1";
            };
          };
          behaviour = {
            # auto_suggestions = false, -- Experimental stage
            # auto_suggestions_respect_ignore = false,
            auto_apply_diff_after_generation = true;
            # jump_result_buffer_on_finish = false,
            # support_paste_from_clipboard = false,
            # enable_cursor_planning_mode = false,
            # enable_claude_text_editor_tool_mode = false,
            use_cwd_as_project_root = true;
            support_paste_from_clipboard = true;
          };
          mappings.sidebar.close = "q"; # TODO: actually set (list) but idk how to do that
          file_selector.provider = "telescope";
          selector.provider = "telescope";

          #compat = [ "avante_commands" "avante_mentions" ];
        };
      };

      codecompanion = {
        enable = true;
        settings.strategies = {
          chat = {
            adapter = "copilot";
          };
          inline = {
            adapter = "copilot";
          };
          cmd = {
            adapter = "copilot";
          };
        };
      };

      blink-compat = {
        enable = true;
      };

      blink-copilot.enable = true;
      blink-cmp = {
        enable = true;
        settings = {
          keymap = {
            preset = "enter";
            "<A-Tab>" = [
              "snippet_forward"
              "fallback"
            ];
            "<A-S-Tab>" = [
              "snippet_backward"
              "fallback"
            ];
            "<Tab>" = [
              "select_next"
              "fallback"
            ];
            "<S-Tab>" = [
              "select_prev"
              "fallback"
            ];
          };

          appearance = {
            use_nvim_cmp_as_default = true;
            nerd_font_variant = "mono";
          };

          sources = {
            default = [
              "lsp"
              "path"
              "snippets"
              "emoji"
              "buffer"
              "copilot"
              "codecompanion"
              "avante_commands"
              "avante_mentions"
              "avante_files"
            ];
            providers = {
              emoji = {
                name = "emoji";
                module = "blink.compat.source";
              };
              copilot = {
                name = "copilot";
                module = "blink-copilot";
                score_offset = 100;
                async = true;
              };
              avante_commands = {
                name = "avante_commands";
                module = "blink.compat.source";
                score_offset = 90; # show at a higher priority than lsp
                opts = { };
              };
              avante_files = {
                name = "avante_commands";
                module = "blink.compat.source";
                score_offset = 100; # show at a higher priority than lsp
                opts = { };
              };
              avante_mentions = {
                name = "avante_mentions";
                module = "blink.compat.source";
                score_offset = 1000; # show at a higher priority than lsp
                opts = { };
              };
            };
          };

          signature.enabled = true;
          # TODO: maybe checkout keybinds from https://github.com/oddlama/nix-config/commit/4d2b1866260f62afb249ba4a4afa98ef6add702a
          completion = {
            list.selection = {
              preselect = false;
              auto_insert = true;
            };
            documentation.auto_show = true;
          };
        };
      };

      # TODO use "ray-x/lsp_signature.nvim"
    };

    #extraConfigLuaPost = ''
    #  -- monkeypatch cmp.ConfirmBehavior for Avante
    #  require("cmp").ConfirmBehavior = {
    #    Insert = "insert",
    #    Replace = "replace",
    #  }
    #'';

    #extraConfigLuaPost = ''
    #   local cmp = require "cmp"
    #   cmp.setup.cmdline(":", {
    #     mapping = cmp.mapping.preset.cmdline(),
    #     sources = {
    #       { name = "cmdline" },
    #       { name = "cmp-cmdline-history" },
    #     },
    #   })
    # '';
  };
}
