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
      #copilot-cmp.enable = true;
      #copilot-chat.enable = true;

      avante = {
        enable = true;
        settings = {
          provider = "copilot";
          auto_suggestions_frequency = "copilot";
          copilot = {
            model = "claude-3.5-sonnet";
          };
          file_selector = {
            provider = "fzf";
            provider_opts = { };
          };

          #compat = [ "avante_commands" "avante_mentions" ];
        };
      };

      blink-compat = {
        enable = true;
      };

      blink-cmp-copilot.enable= true;
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
                module = "blink-cmp-copilot";
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
          completion = {
            list.selection = "manual";
            #   menu = {
            #     border = "none";
            #     draw = {
            #       gap = 1;
            #       treesitter = [ "lsp" ];
            #       columns = [
            #         {
            #           __unkeyed-1 = "label";
            #         }
            #         {
            #           __unkeyed-1 = "kind_icon";
            #           __unkeyed-2 = "kind";
            #           gap = 1;
            #         }
            #         { __unkeyed-1 = "source_name"; }
            #       ];
            #     };
            #   };
            #   trigger = {
            #     show_in_snippet = false;
            #   };
            documentation = {
              auto_show = true;
              #     window = {
              #       border = "rounded";
              #     };
            };
            #   accept = {
            #     auto_brackets = {
            #       enabled = true;
            #     };
            #   };
          };
        };
      };

      # TODO use "ray-x/lsp_signature.nvim"
    };

    extraConfigLuaPost = ''
      -- monkeypatch cmp.ConfirmBehavior for Avante
      require("cmp").ConfirmBehavior = {
        Insert = "insert",
        Replace = "replace",
      }
    '';

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
