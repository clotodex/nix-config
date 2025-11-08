{ pkgs, ... }:
{
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
      #(nerdfonts.override {fonts = ["NerdFontsSymbolsOnly"];})
      nerd-fonts.symbols-only
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
      #noto-fonts-extra
      # nerd-fonts
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

      dejavu_fonts
      segoe-ui-ttf
      jetbrains-mono

    ];

    fontconfig.defaultFonts = {
      serif = [ "IBM Plex Serif" ];
      sansSerif = [ "Segoe UI" ];
      emoji = [ "Segoe UI Emoji" ];
      monospace = [
        # No need for patched nerd fonts, kitty can pick up on them automatically,
        # and ideally every program should do that: https://sw.kovidgoyal.net/kitty/faq/#kitty-is-not-able-to-use-my-favorite-font
        "JetBrains Mono"
      ];
    };
  };
}
