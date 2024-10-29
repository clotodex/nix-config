{pkgs, ...}: {
  fonts = {
    # Always prefer emojis even if the original font would provide a glyph
    fontconfig.localConf = ''
      <?xml version="1.0"?>
      <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
      <fontconfig>
          <alias binding="weak">
              <family>monospace</family>
              <prefer>
                  <family>emoji</family>
              </prefer>
          </alias>
          <alias binding="weak">
              <family>sans-serif</family>
              <prefer>
                  <family>emoji</family>
              </prefer>
          </alias>
          <alias binding="weak">
              <family>serif</family>
              <prefer>
                  <family>emoji</family>
              </prefer>
          </alias>
      </fontconfig>
    '';

    enableDefaultPackages = true;
    enableGhostscriptFonts = true;

    packages = with pkgs; [
      (nerdfonts.override {fonts = ["NerdFontsSymbolsOnly"];})
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-emoji
      noto-fonts-extra
      # nerd-fonts
      noto-fonts-emoji
      liberation_ttf
      fira-code
      fira-code-symbols
      mplus-outline-fonts.githubRelease
      dina-font
      proggyfonts

      corefonts
      font-awesome
      source-sans
      source-serif
      source-sans-pro
      source-serif-pro
      source-code-pro
      roboto
    ];
  };

  stylix.fonts = {
    serif = {
      package = pkgs.dejavu_fonts;
      name = "IBM Plex Serif";
    };

    sansSerif = {
      package = pkgs.segoe-ui-ttf;
      name = "Segoe UI";
    };

    monospace = {
      # No need for patched nerd fonts, kitty can pick up on them automatically,
      # and ideally every program should do that: https://sw.kovidgoyal.net/kitty/faq/#kitty-is-not-able-to-use-my-favorite-font
      package = pkgs.jetbrains-mono;
      name = "JetBrains Mono";
    };

    emoji = {
      package = pkgs.segoe-ui-ttf;
      name = "Segoe UI Emoji";
    };
  };
}
