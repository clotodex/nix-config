{
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    concatMap
    elem
    flip
    getExe
    mkIf
    mkMerge
    optionals
    ;

  # rofi-drun = "rofi -show drun -theme ~/.config/rofi/launchers/type-1/style-10.rasi";
  rofi-drun = "rofi -show drun -theme ~/.config/rofi/launchers/type-7/style-custom.rasi";

  screenshotarea = "hyprctl keyword animation 'fadeOut,0,0,default'; grimblast --notify copysave area; hyprctl keyword animation 'fadeOut,1,4,default'";
  screenshotareacopy = "hyprctl keyword animation 'fadeOut,0,0,default'; grimblast --notify copy area; hyprctl keyword animation 'fadeOut,1,4,default'";
  # TODO: workspace = special:exposed,gapsout:20,gapsin:10,bordersize:2,border:true,shadow:true
in {
  wayland.windowManager.hyprland.settings = {
    bind =
      [
        # Applications
        "SUPER SHIFT, B, exec, ~/.config/waybar/launch.sh"
        "SUPER CTRL, F, exec, firefox -P"
        "SUPER CTRL, B, exec, google-chrome --ozone-platform-hint=auto --enable-features=WebRTCPipeWireCapturer"
        "SUPER CTRL, M, exec, telegram-desktop"
        "SUPER CTRL, S, exec, slack --ozone-platform=wayland --enable-features=WebRTCPipeWireCapturer'"
        "SUPER, escape, exec, ${rofi-drun}"
        "SUPER, r, exec, killall rofi || ${rofi-drun}"
        "SUPER, L, exec, swaylock"
        "SUPER, F1, exec, ~/.config/hypr/scripts/show_keybinds.sh"
        "SUPER SHIFT, X, exec, hyprpicker -a -n"
        "SUPER, T, exec, kitty"
        "MOD5, T, exec, kitty"

        "SUPER SHIFT, Z, exec, pypr zoom"
        "SUPER, Space, exec, pypr layout_center toggle"
        "SUPER SHIFT, W, exec, ~/.config/hypr/scripts/shuffle_wallpaper.sh"

        #bindel=, XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
        #bindel=, XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
        #bindel=, XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
        #bindel=, XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle

        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPause, exec, playerctl play-pause"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"
        ", XF86KbdBrightnessUp, exec, brightnessctl -d '*::kbd_backlight' set +1"
        ", XF86KbdBrightnessDown, exec, brightnessctl -d '*::kbd_backlight' set 1-"
        "SUPER, K, exec, brightnessctl -d '*::kbd_backlight' set 1+"
        "SUPER SHIFT, K, exec, brightnessctl -d '*::kbd_backlight' set 1-"

        #+bindel =, XF86MonBrightnessDown, exec, brightnessctl set 2%-
        #+bindel =, XF86MonBrightnessUp, exec, brightnessctl set +2%

        "SUPER, P, exec, ${screenshotarea}"
        "SUPER SHIFT, P, exec, ${screenshotareacopy}"
        "SUPER, S, exec, grimblast --notify --cursor copysave output"
        ", Print, exec, grimblast --notify --cursor copysave output"

        "SUPER, Q, killactive,"
        "SUPER SHIFT, Q, exit," # old: mod shift esc
        "SUPER, return, fullscreen,1"
        "SUPER, F, togglefloating,"

        #bind = ALT, Tab, bringactivetotop,
        #bind = ALT SHIFT, Tab, cycleprev,
        #bind = ALT SHIFT, Tab, bringactivetotop,

        "SUPER, g, togglegroup,"
        "SUPER, tab, changegroupactive,"

        "SUPER + CTRL + SHIFT,q,exit"

        # Applications
        "SUPER,code:49,exec,${rofi-drun}" # SUPER+^
        ",Menu,exec,${rofi-drun}"

        # Shortcuts & Actions
        #TODO:"SUPER + SHIFT,s,exec,${getExe pkgs.scripts.screenshot-area}"
        #TODO:"SUPER,F11,exec,${getExe pkgs.scripts.screenshot-area-scan-qr}"
        #TODO:"SUPER,F12,exec,${getExe pkgs.scripts.screenshot-screen}"

        # Per-window actions
        "SUPER,q,killactive,"
        "SUPER + SHIFT,return,fakefullscreen,"
        "SUPER,f,togglefloating"

        "SUPER,tab,cyclenext,"
        "ALT,tab,cyclenext,"
        "SUPER + SHIFT,tab,cyclenext,prev"
        "ALT + SHIFT,tab,cyclenext,prev"
        "SUPER,r,submap,resize"

        "SUPER,left,movefocus,l"
        "SUPER,right,movefocus,r"
        "SUPER,up,movefocus,u"
        "SUPER,down,movefocus,d"

        "SUPER + SHIFT,left,movewindow,l"
        "SUPER + SHIFT,right,movewindow,r"
        "SUPER + SHIFT,up,movewindow,u"
        "SUPER + SHIFT,down,movewindow,d"

        "SUPER,comma,workspace,-1"
        "SUPER,period,workspace,+1"
        "SUPER + SHIFT,comma,movetoworkspacesilent,-1"
        "SUPER + SHIFT,period,movetoworkspacesilent,+1"

        "SUPER,0,workspace,10"
        "SUPER + SHIFT,0,movetoworkspacesilent,10"
      ]
      ++ flip concatMap (map toString (lib.lists.range 1 9)) (
        x: [
          "SUPER,${x},workspace,${x}"
          "SUPER + SHIFT,${x},movetoworkspacesilent,${x}"
        ]
      );
    bindm = [
      # mouse movements
      "SUPER, mouse:272, movewindow"
      "SUPER, mouse:273, resizewindow"
      "SUPER ALT, mouse:272, resizewindow"
    ];
  };
}
