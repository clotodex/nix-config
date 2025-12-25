{
  pkgs,
  lib,
  config,
  ...
}:
let
  # TODO: auto-allow screensharing for some apps that have inbuilt controls.
  # TODO: idle setup, wl-clipboard-history, awww, swww-daemon, touchpad scroll workspaces

  script-shuffle-wallpaper = pkgs.writeShellScriptBin "script" ''
    wallpaper_dir="$HOME/.config/wallpapers/all"
    wallpaper_out="$HOME/.config/wallpapers/selected"

    mkdir -p "$wallpaper_out"

    all_wallpapers="$(${pkgs.ripgrep}/bin/rg -u --files $wallpaper_dir)"
    chosen_wallpaper="$(echo "$all_wallpapers" | shuf | head -n 1)"
    cp "$chosen_wallpaper" "$wallpaper_out/wallpaper.jpg"

    # get colorscheme from image
    # wallust run -Tsq "$wallpaper_out/wallpaper.jpg"


    ${pkgs.swww}/bin/swww img "$chosen_wallpaper" --transition-bezier .43,1.19,1,.4 --transition-fps=60  --transition-type=wipe --transition-duration=0.7 --transition-pos "$( hyprctl cursorpos )"
  '';

  todoKeybinds = [
    "SUPER SHIFT, W, exec, ${lib.getExe script-shuffle-wallpaper}"

  ];

in
{
  xdg.portal = {
    #xdgOpenUsePortal = true;
    #wlr.enable = true;
    config.niri = {
      default = [
        "gtk"
        "gnome"
      ];
      "org.freedesktop.impl.portal.Access" = [ "gtk" ];
      "org.freedesktop.impl.portal.Notification" = [ "gtk" ];
      "org.freedesktop.impl.portal.FileChooser" = [ "xdg-desktop-portal-gtk" ];
      "org.freedesktop.impl.portal.ScreenCast" = [ "xdg-desktop-portal-gnome" ];
      "org.freedesktop.impl.portal.Screenshot" = [ "xdg-desktop-portal-gnome" ];
    };
    configPackages = lib.mkAfter [
      pkgs.niri
    ];
    extraPortals = lib.mkAfter [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-gnome
    ];
  };

  home.packages = [
    pkgs.scripts.niri-consume-stack
  ];

  programs.niri.settings = {
    xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite-stable;
    input = {
      keyboard = {
        xkb = {
          layout = "de";
          variant = "nodeadkeys";
        };
        repeat-rate = 60;
        repeat-delay = 235;
        numlock = true;
      };
      touchpad = {
        tap = true;
        dwt = true;
        natural-scroll = true;
        scroll-factor = 0.7;
        click-method = "clickfinger";
        # accel-speed 0.2
        # TODO: accel-profile "flat"
      };
      mouse = {
        # off
        # natural-scroll
        # accel-speed 0.2
        # accel-profile "flat"
        # scroll-method "no-scroll"
      };
    };

    outputs."eDP-1" = {
      mode = {
        width = 2880;
        height = 1800;
      };
      scale = 1.33;
    };

    layout = {
      gaps = 4;
      center-focused-column = "never";
      always-center-single-column = true;

      tab-indicator = {
        hide-when-single-tab = true;
        place-within-column = true;
        active.color = "#98c379";
        # blue
        inactive.color = "#5ca5e2";
        urgent.color = "#ff5050";
        gaps-between-tabs = 8;
        length.total-proportion = 0.66667;
        width = 6;
        corner-radius = 8;
        position = "left";
      };

      empty-workspace-above-first = true;
      preset-column-widths = [
        { proportion = 0.33333; }
        { proportion = 0.5; }
        { proportion = 0.66667; }
        { proportion = 1.0; } # so that a full cycle is possible
      ];
      default-column-width = {
        proportion = 0.5;
      };
      preset-window-heights = [
        { proportion = 0.33333; }
        { proportion = 0.5; }
        { proportion = 0.66667; }
        { proportion = 1.0; } # so that a full cycle is possible
      ];

      focus-ring = {
        enable = true;
        width = 1;
        #active.color = "#7fc8ff";
        active.color = "#5ca5e2";
        # TODO: can I drop an unfocused border completely?
        inactive.color = "#505050";
      };

      border.enable = false;

      # will be used by window rules
      shadow = {
        enable = false;
        softness = 30;
        spread = 5;
        offset = {
          x = 0;
          y = 5;
        };
        color = "#0007";
      };

      struts = { };
    };

    prefer-no-csd = true;
    screenshot-path = "~/screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";

    environment = {
      "QT_QPA_PLATFORM" = "wayland";
      "XDG_SESSION_TYPE" = "wayland";
      "NIXOS_OZONE_WL" = "1";
      "MOZ_ENABLE_WAYLAND" = "1";
      "MOZ_WEBRENDER" = "1";
      "_JAVA_AWT_WM_NONREPARENTING" = "1";
      "QT_WAYLAND_DISABLE_WINDOWDECORATION" = "1";
      "GDK_BACKEND" = "wayland";
      "XDG_SCREENSHOTS_DIR" = "/home/clotodex/screenshots";
    };

    window-rules = [
      {
        matches = [ { is-floating = true; } ];
        shadow.enable = true;
      }

      ## TODO: set up tabindicator inactive color for specific classes (finding a terminal window in the stack - or vim, idk) :)

      {
        matches = [
          { app-id = "firefox$"; }
          { app-id = "google-chrome"; }
          { app-id = "spotify"; }
          { app-id = "^org\.telegram\.desktop$"; }
        ];
        excludes = [
          {
            app-id = "google-chrome";
            is-floating = true;
          }
          {
            app-id = "^org\.telegram\.desktop$";
            title = "^Media viewer$";
          }
        ];
        # TODO: exclude floating

        open-maximized = true;
        default-column-display = "tabbed";
      }
      {
        matches = [
          { app-id = "google-chrome"; }
          {
            app-id = "firefox$";
            title = "^Picture-in-Picture$";
          }
        ];
        excludes = [ { title = "- Google Chrome$"; } ];
        open-floating = true;
        open-focused = false;
      }
      # Google meet pop-outs should be bottom right
      # TODO: feature request: make this float ACROSS workspaces (or use nirium follow)
      {
        matches = [
          {
            app-id = "google-chrome";
            title = "^Meet.*";
          }
        ];
        excludes = [ { title = "- Google Chrome$"; } ];
        open-floating = true;
        default-floating-position = {
          x = 0;
          y = 0;
          relative-to = "bottom-right";
        };
        default-column-width = {
          fixed = 400;
        };
        default-window-height = {
          fixed = 400;
        };
      }
    ];
    # Block out notifications from screencasts.
    layer-rules = [
      {
        matches = [ { namespace = "^notifications$"; } ];

        block-out-from = "screencast";
      }
    ];

    switch-events =
      with config.lib.niri.actions;
      let
        spawn-sh = spawn "sh" "-c";
      in
      {
        tablet-mode-on.action = spawn-sh "notify-send tablet-mode-on";
        tablet-mode-off.action = spawn-sh "notify-send tablet-mode-off";
        lid-open.action = spawn-sh "notify-send lid-open";
        lid-close.action = spawn-sh "notify-send lid-close";
      };

    binds =
      with config.lib.niri.actions;
      let
        # helperfunctions
        allow-locked-action = action: {
          inherit action;
          allow-when-locked = true;
        };

        overlay-action = title: action: {
          inherit action;
          hotkey-overlay = { inherit title; };
        };

        no-repeat-action = action: {
          inherit action;
          repeat = false;
        };

        spawn-launcher = spawn-sh "rofi -show drun -theme ~/.config/rofi/launchers/type-7/style-custom.rasi";

        script-shuffle-wallpaper = pkgs.writeShellScriptBin "script" ''
          wallpaper_dir="$HOME/.config/wallpapers/all"
          wallpaper_out="$HOME/.config/wallpapers/selected"

          mkdir -p "$wallpaper_out"

          all_wallpapers="$(${pkgs.ripgrep}/bin/rg -u --files $wallpaper_dir)"
          chosen_wallpaper="$(echo "$all_wallpapers" | shuf | head -n 1)"
          cp "$chosen_wallpaper" "$wallpaper_out/wallpaper.jpg"

          # get colorscheme from image
          # wallust run -Tsq "$wallpaper_out/wallpaper.jpg"


          ${pkgs.swww}/bin/swww img "$chosen_wallpaper" --transition-bezier .43,1.19,1,.4 --transition-fps=60  --transition-type=wipe --transition-duration=0.7 --transition-pos "$( hyprctl cursorpos )"
        '';
      in

      # TODO: wlr-which-key
      # TODO: focus-or-spawn
      # TODO: burst-collector? listen to eventstream, if window is openend within 500ms of previous window, consume into column

      {
        # INFO: application launchers
        "Mod+Ctrl+F".action = spawn-sh "firefox -P";
        "Mod+Ctrl+B".action =
          spawn-sh "google-chrome-stable --ozone-platform-hint=auto --enable-features=WebRTCPipeWireCapturer; sleep 1"; # ; ${lib.getExe pkgs.scripts.niri-consume-stack} -q";
        "Mod+Ctrl+M".action = spawn-sh "Telegram";
        "Mod+Ctrl+S".action =
          spawn-sh "slack --ozone-platform=wayland --enable-features=WebRTCPipeWireCapturer";
        "Mod+Shift+W".action = spawn-sh "${lib.getExe script-shuffle-wallpaper}";

        # INFO: essentials
        "Mod+T" = overlay-action "Open a Terminal: kitty" (spawn "kitty");
        # backup since on multiple pcs the mod key broke
        "Mod5+T".action = spawn "kitty";
        "Mod+Escape" = overlay-action "Run an Application: rofi" spawn-launcher;
        "Menu".action = spawn-launcher;
        "Mod+L" = overlay-action "Lock the Screen: swaylock" (spawn "swaylock");

        # INFO: Media & Brightness
        XF86AudioRaiseVolume = allow-locked-action <| spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+";

        XF86AudioLowerVolume = allow-locked-action <| spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-";
        XF86AudioMute = allow-locked-action <| spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        XF86AudioMicMute = allow-locked-action <| spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";

        XF86AudioPlay = allow-locked-action <| spawn-sh "playerctl play-pause";
        XF86AudioStop = allow-locked-action <| spawn-sh "playerctl stop";
        XF86AudioPrev = allow-locked-action <| spawn-sh "playerctl previous";
        XF86AudioNext = allow-locked-action <| spawn-sh "playerctl next";

        XF86MonBrightnessUp = allow-locked-action <| spawn "brightnessctl" "--class=backlight" "set" "+2%";
        XF86MonBrightnessDown =
          allow-locked-action <| spawn "brightnessctl" "--class=backlight" "set" "2%-";

        XF86KbdBrightnessUp = allow-locked-action <| spawn-sh "brightnessctl -d '*::kbd_backlight' set +1";
        XF86KbdBrightnessDown =
          allow-locked-action <| spawn-sh "brightnessctl -d '*::kbd_backlight' set 1-";
        "Mod+K" = allow-locked-action <| spawn-sh "brightnessctl -d '*::kbd_backlight' set 1+";
        "Mod+Shift+K" = allow-locked-action <| spawn-sh "brightnessctl -d '*::kbd_backlight' set 1-";

        # Powers off the monitors. To turn them back on, do any input
        "Mod+Shift+P".action = power-off-monitors;

        # INFO: core
        "Mod+Shift+Ssharp".action = show-hotkey-overlay;
        "Mod+Shift+Q".action = quit;
        "Ctrl+Alt+Delete".action = quit;

        "Mod+O" = no-repeat-action toggle-overview;
        "Mod+Space" = no-repeat-action toggle-overview;

        "Mod+Q" = no-repeat-action close-window;

        # If vm or similar is grabbing all keyboard input, cancel and grab back
        "Mod+Shift+Escape" = {
          allow-inhibiting = false;
          action = toggle-keyboard-shortcuts-inhibit;
        };

        "Print".action.screenshot = [ ];
        "Mod+P".action.screenshot = [ ];
        "Ctrl+Print".action.screenshot-screen = [ ];
        "Alt+Print".action.screenshot-window = [ ];

        # INFO: resizing

        # TODO: probably use wlr-which-key for more complex options

        "Mod+Return".action = maximize-column;
        "Mod+Shift+Return".action = fullscreen-window;
        # FIXME: do I need multiple bindings?
        "Mod+F".action = maximize-column;
        "Mod+Shift+F".action = fullscreen-window;

        "Mod+R".action = switch-preset-column-width;
        "Mod+Shift+R".action = switch-preset-window-height;
        # FIXME:unused?
        "Mod+Ctrl+R".action = reset-window-height;

        # TODO: Mod+Ctrl+F { expand-column-to-available-width; }

        "Mod+C".action = center-column;

        # Center all fully visible columns on screen.
        # FIXME:used?
        "Mod+Ctrl+C".action = center-visible-columns;

        "Mod+Shift+Alt+Right".action = set-column-width "+5%";
        "Mod+Shift+Alt+Left".action = set-column-width "-5%";
        "Mod+Shift+Alt+Up".action = set-window-height "-5%";
        "Mod+Shift+Alt+Down".action = set-window-height "+5%";

        # Move the focused window between the floating and the tiling layout.
        # FIXME: better keybind idea?
        "Mod+V".action = toggle-window-floating;
        "Mod+Shift+V".action = switch-focus-between-floating-and-tiling;

        # FIXME: better keybind idea?
        "Mod+W".action = toggle-column-tabbed-display;

        "Mod+Shift+C".action = spawn (lib.getExe pkgs.scripts.niri-consume-stack);

        # INFO: movement

        "Mod+Left".action = focus-column-left;
        "Mod+Right".action = focus-column-right;
        # TODO: if only one window in column, focus workspace
        "Mod+Down".action = focus-window-down;
        "Mod+Up".action = focus-window-up;

        # INFO: columns

        # FIXME: better keybind idea?
        "Mod+Period".action = consume-or-expel-window-left;
        "Mod+Minus".action = consume-or-expel-window-right;
        "Mod+Comma".action = consume-window-into-column;
        # FIXME: needed?
        "Mod+Plus".action = expel-window-from-column;

        "Mod+Shift+Left".action = move-column-left;
        "Mod+Shift+Right".action = move-column-right;
        # TODO: if only one window in column, move to (and focus) workspace
        "Mod+Shift+Down".action = move-window-down;
        "Mod+Shift+Up".action = move-window-up;

        # INFO: workspaces

        "Mod+Ctrl+Left".action = focus-column-first;
        "Mod+Ctrl+Down".action = focus-workspace-down;
        "Mod+Ctrl+Up".action = focus-workspace-up;
        "Mod+Ctrl+Right".action = focus-column-last;

        "Mod+Ctrl+Shift+Left".action = move-column-to-first;
        "Mod+Ctrl+Shift+Right".action = move-column-to-last;
        "Mod+Ctrl+Shift+Down".action = move-column-to-workspace-down;
        "Mod+Ctrl+Shift+Up".action = move-column-to-workspace-up;

        # TODO: figure out how this "flows"
        # https://github.com/YaLTeR/niri/discussions/2842#discussioncomment-15066835
        # TODO: moving workspaces through keybinds in overview would be nice
        "Mod+Alt+Down".action = move-workspace-down;
        "Mod+Alt+Up".action = move-workspace-up;

        "Mod+Tab".action = focus-workspace-down;
        "Mod+Shift+Tab".action = focus-workspace-up;

        "Mod+Numbersign".action = focus-workspace-previous; # #
        "Mod+asciicircum".action = focus-workspace-previous; # ^

        "Mod+1".action = focus-workspace 1;
        "Mod+2".action = focus-workspace 2;
        "Mod+3".action = focus-workspace 3;
        "Mod+4".action = focus-workspace 4;
        "Mod+5".action = focus-workspace 5;
        "Mod+6".action = focus-workspace 6;
        "Mod+7".action = focus-workspace 7;
        "Mod+8".action = focus-workspace 8;
        "Mod+9".action = focus-workspace 9;
        "Mod+0".action = focus-workspace 99; # kind of like "focus-last"
        # "Mod+Shift+1".action = move-column-to-workspace 1;
        # "Mod+Shift+2".action = move-column-to-workspace 2;
        # "Mod+Shift+3".action = move-column-to-workspace 3;
        # "Mod+Shift+4".action = move-column-to-workspace 4;
        # "Mod+Shift+5".action = move-column-to-workspace 5;
        # "Mod+Shift+6".action = move-column-to-workspace 6;
        # "Mod+Shift+7".action = move-column-to-workspace 7;
        # "Mod+Shift+8".action = move-column-to-workspace 8;
        # "Mod+Shift+9".action = move-column-to-workspace 9;

        # Switches focus between the current and the previous workspace.

        # INFO: monitors

        "Mod+Home".action = focus-monitor-left;
        "Mod+End".action = focus-monitor-right;
        "Mod+Shift+Home".action = move-column-to-monitor-left;
        "Mod+Shift+End".action = move-column-to-monitor-right;

        "Mod+Page_Down".action = focus-monitor-down;
        "Mod+Page_Up".action = focus-monitor-up;
        "Mod+Shift+Page_Down".action = move-column-to-monitor-down;
        "Mod+Shift+Page_Up".action = move-column-to-monitor-up;

        # Alternatively, there are commands to move just a single window:
        # Mod+Shift+Ctrl+Left  { move-window-to-monitor-left; }
        # ...

        # And you can also move a whole workspace to another monitor:
        # Mod+Shift+Ctrl+Left  { move-workspace-to-monitor-left; }
        # ...
        "Mod+Ctrl+Home".action = move-workspace-to-monitor-left;
        "Mod+Ctrl+Page_Down".action = move-workspace-to-monitor-down;
        "Mod+Ctrl+Page_Up".action = move-workspace-to-monitor-up;
        "Mod+Ctrl+End".action = move-workspace-to-monitor-right;

        # Alternatively, there are commands to move just a single window:
        # Mod+Ctrl+Page_Down { move-window-to-workspace-down; }
        # ...

        # INFO: mouse and touchpad binds

        # You can bind mouse wheel scroll ticks using the following syntax.
        # These binds will change direction based on the natural-scroll setting.
        #
        # To avoid scrolling through workspaces really fast, you can use
        # the cooldown-ms property. The bind will be rate-limited to this value.
        # You can set a cooldown on any bind, but it's most useful for the wheel.
        "Mod+WheelScrollDown" = {
          cooldown-ms = 150;
          action = focus-workspace-down;
        };
        "Mod+WheelScrollUp" = {
          cooldown-ms = 150;
          action = focus-workspace-up;
        };
        "Mod+Ctrl+WheelScrollDown" = {
          cooldown-ms = 150;
          action = move-column-to-workspace-down;
        };
        "Mod+Ctrl+WheelScrollUp" = {
          cooldown-ms = 150;
          action = move-column-to-workspace-up;
        };

        "Mod+WheelScrollRight".action = focus-column-right;
        "Mod+WheelScrollLeft".action = focus-column-left;
        "Mod+Ctrl+WheelScrollRight".action = move-column-right;
        "Mod+Ctrl+WheelScrollLeft".action = move-column-left;

        # Usually scrolling up and down with Shift in applications results in
        # horizontal scrolling; these binds replicate that.
        "Mod+Shift+WheelScrollDown".action = focus-column-right;
        "Mod+Shift+WheelScrollUp".action = focus-column-left;
        "Mod+Ctrl+Shift+WheelScrollDown".action = move-column-right;
        "Mod+Ctrl+Shift+WheelScrollUp".action = move-column-left;

        # Similarly, you can bind touchpad scroll "ticks".
        # Touchpad scrolling is continuous, so for these binds it is split into
        # discrete intervals.
        # These binds are also affected by touchpad's natural-scroll, so these
        # example binds are "inverted", since we have natural-scroll enabled for
        # touchpads by default.
        # Mod+TouchpadScrollDown { spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.02+"; }
        # Mod+TouchpadScrollUp   { spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.02-"; }

      };
  };
}
