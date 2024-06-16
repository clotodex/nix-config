{
  programs.nixvim.plugins = {
    # Statusline
    lualine = {
      enable = true;
      extensions = ["fzf" "nvim-dap-ui" "symbols-outline" "trouble" "neo-tree" "quickfix" "fugitive"];
      componentSeparators.left = null;
      componentSeparators.right = null;
      # componentSeparators.left = "|";
      # componentSeparators.right = "|";
      # sectionSeparators.left = "";
      # sectionSeparators.right = "";
      sections = {
        lualine_a = ["mode"];
        lualine_b = ["branch" "filename"];
        lualine_c = ["diff" "diagnostics"];
        lualine_x = ["encoding" "fileformat" "filetype"];
        lualine_y = ["progress"];
        lualine_z = ["location"];
      };
      inactiveSections = {
        lualine_a = ["filename"];
        lualine_b = [];
        lualine_c = ["diagnostics"];
        lualine_x = [];
        lualine_y = [];
        lualine_z = ["location"];
      };
    };

    # Line indentation markers
    indent-blankline.enable = true;

    # Rainbow parentheses
    rainbow-delimiters.enable = true;

    # Status updates for LSP progress in right bottom corner.
    fidget.enable = true;
    # Show colors
    nvim-colorizer.enable = true;

    # Breadcrumbs
    # TODO navic.enable = true; or dropbar?
  };
}
