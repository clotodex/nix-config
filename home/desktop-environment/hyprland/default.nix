{
  lib,
  pkgs,
  inputs,
  ...
}:
let
  inherit (lib)
    concatMap
    elem
    flip
    getExe
    mkIf
    mkMerge
    optionals
    ;

  rofi-drun = "rofi -show drun -theme ~/.config/rofi/launchers/type-1/style-10.rasi";

  scroller_scripts = import ./hyprscroller.nix { inherit pkgs; };
in
{
  imports = [
    ./keybinds.nix
  ];

  home.packages = with pkgs; [
    # TODO: inputs.rose-pine-hyprcursor.packages.${system}.default
    scroller_scripts.scroller_listen
    scroller_scripts.scroller_read
    scroller_scripts.scroller_toggle
  ];

    #home.file."config/hypr/xdph.conf".text = ''
    #  screencopy {
    #    allow_token_by_default = true
    #  }
    #'';

  wayland.windowManager.hyprland = {
    enable = true;
    #package = null; # inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    #portalPackage = null; #inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    package = null; # inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage = null;
    #inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;

    plugins = [ inputs.hyprland-plugins.packages.${pkgs.stdenv.hostPlatform.system}.hyprscrolling ];
    #plugins = [
    #  inputs.Hyprspace.packages."x86_64-linux".Hyprspace
    #];
    systemd.variables = [ "--all" ];
    settings = mkMerge [
      {
        env =
          # TODO: optional nvidia
          [
            # See https://wiki.hyprland.org/Nvidia/
            #  "LIBVA_DRIVER_NAME,nvidia"
            #  "XDG_SESSION_TYPE,wayland"
            #  "GBM_BACKEND,nvidia-drm"
            #  "__GLX_VENDOR_LIBRARY_NAME,nvidia"
            #]
            #++ [
            "XDG_SESSION_TYPE,wayland"

            "NIXOS_OZONE_WL,1"
            "MOZ_ENABLE_WAYLAND,1"
            "MOZ_WEBRENDER,1"
            "_JAVA_AWT_WM_NONREPARENTING,1"
            "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
            "QT_QPA_PLATFORM,wayland"
            #"SDL_VIDEODRIVER,wayland"
            "GDK_BACKEND,wayland"

            "XDG_SCREENSHOTS_DIR,/home/clotodex/screenshots"

            #"HYPRCURSOR_THEME,rose-pine-hyprcursor"
            "AQ_DRM_DEVICES,/dev/dri/card1" # :/dev/dri/card0"
            "AQ_NO_MODIFIERS,1"
          ];

        animations = {
          enabled = true;
          animation = [
            "windows, 1, 4, default, slide"
            "windowsOut, 1, 4, default, slide"
            "windowsMove, 1, 4, default"
            "border, 1, 2, default"
            "fade, 1, 4, default"
            "fadeDim, 1, 4, default"
            "workspaces, 1, 4, default"
          ];
        };

        decoration = {
          rounding = 4;
          active_opacity = 1.0;
          inactive_opacity = 0.8;

          # do i need this?
          blur = {
            enabled = true;
            size = 3;
            passes = 3;
            new_optimizations = true;
            ignore_opacity = true;
          };
          shadow = {
            enabled = true;
            ignore_window = true;
            offset = "2 2";
            range = 4;
            render_power = 2;
            color = "0x66000000";
          };
          blurls = "waybar";
        };
        exec-once = [
          "uwsm finalize"
          #"dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
          #"systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
          #"systemctl --user restart xdg-desktop-portal.service"
          #"${pkgs.waybar}/bin/waybar"
          # TODO: are all these exec-ones needed or can we switch them to uwsm?
          "${pkgs.swaynotificationcenter}/bin/swaync"
          # "${lib.getExe pkgs.whisper-overlay}"
          "wl-clipboard-history -t"
          "${pkgs.hypridle}/bin/hypridle"

          "${pkgs.swww}/bin/swww-daemon"
          "${pkgs.swww}/bin/swww img ~/.config/hypr/tmp/wallpaper.jpg"
          #"~/.config/waybar/launch.sh"

          #"kitty /home/clotodex/.config/hypr/scripts/autostart.sh"
          #"bash /home/clotodex/.config/hypr/scripts/dynamic_battery_notify.sh &"
          #"${lib.getExe scroller_scripts.scroller_listen}"
        ];

        input = {
          kb_layout = "de";
          kb_variant = "nodeadkeys";
          follow_mouse = 2;
          numlock_by_default = true;
          repeat_rate = 60;
          repeat_delay = 235;
          # Only change focus on mouse click
          float_switch_override_focus = 0;
          accel_profile = "flat";

          touchpad = {
            natural_scroll = true;
            disable_while_typing = true;
            clickfinger_behavior = true;
            scroll_factor = 0.7;
          };
        };

        general = {
          gaps_in = 5;
          gaps_out = 0;
          border_size = 0;
          no_border_on_floating = true;
          #allow_tearing = true;
          #layout = "dwindle";
          layout = "scrolling";

        };

        cursor = {
          no_warps = true;
          no_hardware_cursors = true;
        };
        debug.disable_logs = false;

        misc = {
          vfr = 1;
          vrr = 1;
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
          mouse_move_focuses_monitor = true;
          mouse_move_enables_dpms = true;
          #enable_swallow = false;
          new_window_takes_over_fullscreen = 1;
          exit_window_retains_fullscreen = true;
        };

        # xwayland.force_zero_scaling = true;
      }
      {
        monitor = [
          ",preferred,auto,1"
          "eDP-1,2880x1800@60,auto,1.33"#,bitdepth,8"
        ];
        workspace = [
        ];
      }
    ];

    # TODO: there seems to not be height cycling yet
    extraConfig = ''
      submap=resize
      binde=,right,resizeactive,80 0
      binde=,left,resizeactive,-80 0
      binde=,up,resizeactive,0 -80
      binde=,down,resizeactive,0 80
      binde=SHIFT,right,resizeactive,10 0
      binde=SHIFT,left,resizeactive,-10 0
      binde=SHIFT,up,resizeactive,0 -10
      binde=SHIFT,down,resizeactive,0 10
      binde=,t,layoutmsg,fit active
      binde=,a,layoutmsg,fit all
      binde=,b,layoutmsg,fit tobeg
      binde=,e,layoutmsg,fit toend
      binde=,v,layoutmsg,fit visible
      binde=,m,layoutmsg,focus t
      binde=,space,layoutmsg,colresize +conf
      binde=SHIFT,space,layoutmsg,colresize -conf
      bind=,return,submap,reset
      bind=,escape,submap,reset
      submap=reset

      env=WLR_DRM_NO_ATOMIC,1
      windowrule = immediate, class:^(cs2)$

      windowrule = idleinhibit focus, class:mpv
      windowrule = idleinhibit fullscreen, class:firefox


      binds {
        focus_preferred_method = 1
        movefocus_cycles_fullscreen = false
      }

      gestures {
        workspace_swipe = false
      }

      $opacityrule = opacity 0.95 override 0.8 override 1 override
      windowrule = $opacityrule,class:^(kitty)$ # set opacity to 0.9 active, 0.8 inactive and 1 fullscreen for everything
      windowrule = $opacityrule,class:^(Slack)$
      windowrule = $opacityrule,class:^(signal)$
      windowrule = $opacityrule,class:^(org.telegram.desktop)$

      windowrule = size 640 360, title:(Picture-in-Picture)
      windowrule = pin, title:^(Picture-in-Picture)$
      windowrule = move 1906 14, title:(Picture-in-Picture)
      windowrule = float, title:^(Picture-in-Picture)$

      windowrule = size 640 360, title:(Picture-in-picture)
      windowrule = pin, title:^(Picture-in-picture)$
      windowrule = move 1906 14, title:(Picture-in-picture)
      windowrule = float, title:^(Picture-in-picture)$
    '';
  };
}
