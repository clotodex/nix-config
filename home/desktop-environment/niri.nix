{
  pkgs,
  lib,
  config,
  ...
}:
{
  xdg.portal = {
    config.niri = {
      default = [
        "gnome"
      ];
      "org.freedesktop.impl.portal.Access" = [ "gtk" ];
      "org.freedesktop.impl.portal.Notification" = [ "gtk" ];
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

      # Next sections include libinput settings.
      # Omitting settings disables them, or leaves them at their default values.
      # All commented-out settings here are examples, not defaults.
      touchpad = {
        # off
        tap = true;
        # disable-while-typing
        dwt = true;
        # dwtp
        # drag false
        # drag-lock
        natural-scroll = true;

        scroll-factor = 0.7;

        click-method = "clickfinger";

        # accel-speed 0.2
        # TODO: accel-profile "flat"

        # scroll-method "two-finger"
        # disabled-on-external-mouse
      };

      mouse = {
        # off
        # natural-scroll
        # accel-speed 0.2
        # accel-profile "flat"
        # scroll-method "no-scroll"
      };
    };

    # Focus windows and outputs automatically when moving the mouse into them.
    # Setting max-scroll-amount="0%" makes it work only on windows already fully on screen.
    # focus-follows-mouse max-scroll-amount="0%"

    # no! workspace-auto-back-and-forth

    # You can configure outputs by their name, which you can find
    # by running `niri msg outputs` while inside a niri instance.
    # The built-in laptop monitor is usually called "eDP-1".
    # Find more information on the wiki:
    # https:#yalter.github.io/niri/Configuration:-Outputs
    # Remember to uncomment the node by removing "/-"!
    outputs."eDP-1" = {
      # Uncomment this line to disable this output.
      # off

      # Resolution and, optionally, refresh rate of the output.
      # The format is "<width>x<height>" or "<width>x<height>@<refresh rate>".
      # If the refresh rate is omitted, niri will pick the highest refresh rate
      # for the resolution.
      # If the mode is omitted altogether or is invalid, niri will pick one automatically.
      # Run `niri msg outputs` while inside a niri instance to list all outputs and their modes.
      mode = {
        width = 2880;
        height = 1800;
      };

      # You can use integer or fractional scale, for example use 1.5 for 150% scale.
      scale = 1.33;

      # Transform allows to rotate the output counter-clockwise, valid values are:
      # normal, 90, 180, 270, flipped, flipped-90, flipped-180 and flipped-270.
      # transform "normal"

      # Position of the output in the global coordinate space.
      # This affects directional monitor actions like "focus-monitor-left", and cursor movement.
      # The cursor can only move between directly adjacent outputs.
      # Output scale and rotation has to be taken into account for positioning:
      # outputs are sized in logical, or scaled, pixels.
      # For example, a 3840×2160 output with scale 2.0 will have a logical size of 1920×1080,
      # so to put another output directly adjacent to it on the right, set its x to 1920.
      # If the position is unset or results in an overlap, the output is instead placed
      # automatically.
      # position x=1280 y=0
    };

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

    # Settings that influence how windows are positioned and sized.
    # Find more information on the wiki:
    # https:#yalter.github.io/niri/Configuration:-Layout
    layout = {
      # Set gaps around windows in logical pixels.
      gaps = 4;

      # When to center a column when changing focus, options are:
      # - "never", default behavior, focusing an off-screen column will keep at the left
      #   or right edge of the screen.
      # - "always", the focused column will always be centered.
      # - "on-overflow", focusing a column will center it if it doesn't fit
      #   together with the previously focused column.
      center-focused-column = "never";
      always-center-single-column = true;

      tab-indicator = {
        hide-when-single-tab = true;
        place-within-column = true;
      };

      # You can customize the widths that "switch-preset-column-width" (Mod+R) toggles between.
      empty-workspace-above-first = true;
      preset-column-widths = [
        { proportion = 0.33333; }
        { proportion = 0.5; }
        { proportion = 0.66667; }
      ];
      default-column-width = {
        proportion = 0.5;
      };
      preset-window-heights = [
        { proportion = 0.33333; }
        { proportion = 0.5; }
        { proportion = 0.66667; }
      ];

      # By default focus ring and border are rendered as a solid background rectangle
      # behind windows. That is, they will show up through semitransparent windows.
      # This is because windows using client-side decorations can have an arbitrary shape.
      #
      # If you don't like that, you should uncomment `prefer-no-csd` below.
      # Niri will draw focus ring and border *around* windows that agree to omit their
      # client-side decorations.
      #
      # Alternatively, you can override it with a window rule called
      # `draw-border-with-background`.

      # You can change how the focus ring looks.
      focus-ring = {
        # Uncomment this line to disable the focus ring.
        # off
        enable = true;

        # How many logical pixels the ring extends out from the windows.
        width = 1;

        # Colors can be set in a variety of ways:
        # - CSS named colors: "red"
        # - RGB hex: "#rgb", "#rgba", "#rrggbb", "#rrggbbaa"
        # - CSS-like notation: "rgb(255, 127, 0)", rgba(), hsl() and a few others.

        # Color of the ring on the active monitor.
        active.color = "#7fc8ff";

        # Color of the ring on inactive monitors.
        #
        # The focus ring only draws around the active window, so the only place
        # where you can see its inactive.color is on other monitors.
        inactive.color = "#505050";

        # You can also use gradients. They take precedence over solid colors.
        # Gradients are rendered the same as CSS linear-gradient(angle, from, to).
        # The angle is the same as in linear-gradient, and is optional,
        # defaulting to 180 (top-to-bottom gradient).
        # You can use any CSS linear-gradient tool on the web to set these up.
        # Changing the color space is also supported, check the wiki for more info.
        #
        # active-gradient from="#80c8ff" to="#c7ff7f" angle=45

        # You can also color the gradient relative to the entire view
        # of the workspace, rather than relative to just the window itself.
        # To do that, set relative-to="workspace-view".
        #
        # inactive-gradient from="#505050" to="#808080" angle=45 relative-to="workspace-view"
      };

      # You can also add a border. It's similar to the focus ring, but always visible.
      border = {
        # The settings are the same as for the focus ring.
        # If you enable the border, you probably want to disable the focus ring.
        enable = false;
      };

      # You can enable drop shadows for windows.
      shadow = {
        # Uncomment the next line to enable shadows.
        # on
        enable = false;

        # By default, the shadow draws only around its window, and not behind it.
        # Uncomment this setting to make the shadow draw behind its window.
        #
        # Note that niri has no way of knowing about the CSD window corner
        # radius. It has to assume that windows have square corners, leading to
        # shadow artifacts inside the CSD rounded corners. This setting fixes
        # those artifacts.
        #
        # However, instead you may want to set prefer-no-csd and/or
        # geometry-corner-radius. Then, niri will know the corner radius and
        # draw the shadow correctly, without having to draw it behind the
        # window. These will also remove client-side shadows if the window
        # draws any.
        #
        # draw-behind-window true

        # You can change how shadows look. The values below are in logical
        # pixels and match the CSS box-shadow properties.

        # Softness controls the shadow blur radius.
        softness = 30;

        # Spread expands the shadow.
        spread = 5;

        # Offset moves the shadow relative to the window.
        offset = {
          x = 0;
          y = 5;
        };

        # You can also change the shadow color and opacity.
        color = "#0007";
      };

      # Struts shrink the area occupied by windows, similarly to layer-shell panels.
      # You can think of them as a kind of outer gaps. They are set in logical pixels.
      # Left and right struts will cause the next window to the side to always be visible.
      # Top and bottom struts will simply add outer gaps in addition to the area occupied by
      # layer-shell panels and regular gaps.
      struts = {
        # left 64
        # right 64
        # top 64
        # bottom 64
      };
    };

    # Add lines like this to spawn processes at startup.
    # Note that running niri as a session supports xdg-desktop-autostart,
    # which may be more convenient to use.
    # See the binds section below for more spawn examples.

    # This line starts waybar, a commonly used bar for Wayland compositors.
    # spawn-at-startup "waybar"

    # To run a shell command (with variables, pipes, etc.), use spawn-sh-at-startup:
    # spawn-sh-at-startup "qs -c ~/source/qs/MyAwesomeShell"

    # Uncomment this line to ask the clients to omit their client-side decorations if possible.
    # If the client will specifically ask for CSD, the request will be honored.
    # Additionally, clients will be informed that they are tiled, removing some client-side rounded corners.
    # This option will also fix border/focus ring drawing behind some semitransparent windows.
    # After enabling or disabling this, you need to restart the apps for this to take effect.
    prefer-no-csd = true;

    # You can change the path where screenshots are saved.
    # A ~ at the front will be expanded to the home directory.
    # The path is formatted with strftime(3) to give you the screenshot date and time.
    screenshot-path = "~/screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";

    # You can also set this to null to disable saving screenshots to disk.
    # screenshot-path null

    # Animation settings.
    # The wiki explains how to configure individual animations:
    # https:#yalter.github.io/niri/Configuration:-Animations
    #animations = {
    #  # Uncomment to turn off all animations.
    #  # off

    #  # Slow down all animations by this factor. Values below 1 speed them up instead.
    #  # slowdown 3.0
    #};

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

    # Window rules let you adjust behavior for individual windows.
    # Find more information on the wiki:
    # https:#yalter.github.io/niri/Configuration:-Window-Rules

    # Work around WezTerm's initial configure bug
    # by setting an empty default-column-width.
    window-rules = [
      {
        matches = [ { is-floating = true; } ];

        shadow.enable = true;
      }

      ## TODO: set up :)
      #{
      #    matches = [{ app-id="^org\.keepassxc\.KeePassXC$"
      #
      #    tab-indicator {
      #        inactive.color "darkred"
      #    }
      #}

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

      # Open the Firefox picture-in-picture player as floating by default.
      {
        # This app-id regular expression will work for both:
        # - host Firefox (app-id is "firefox")
        # - Flatpak Firefox (app-id is "org.mozilla.firefox")
        matches = [
          {
            app-id = "firefox$";
            title = "^Picture-in-Picture$";
          }
        ];
        open-floating = true;
        open-focused = false;
      }
      {
        matches = [ { app-id = "google-chrome"; } ];
        excludes = [ { title = "- Google Chrome$"; } ];
        open-floating = true;
        open-focused = false;
      }
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

      # Example: block out two password managers from screen capture.
      # (This example rule is commented out with a "/-" in front.)
      #/-window-rule {
      #    match app-id=r#"^org\.keepassxc\.KeePassXC$"#
      #    match app-id=r#"^org\.gnome\.World\.Secrets$"#
      #
      #    block-out-from "screen-capture"
      #
      #    # Use this instead if you want them visible on third-party screenshot tools.
      #    # block-out-from "screencast"
      #}
      #
      ## Example: enable rounded corners for all windows.
      ## (This example rule is commented out with a "/-" in front.)
      #/-window-rule {
      #    geometry-corner-radius 12
      #    clip-to-geometry true
      #}
    ];
    # Block out mako notifications from screencasts.
    layer-rules = [
      {
        matches = [ { namespace = "^notifications$"; } ];

        block-out-from = "screencast";
      }
    ];

    binds = with config.lib.niri.actions; {

      # Keys consist of modifiers separated by + signs, followed by an XKB key name
      # in the end. To find an XKB name for a particular key, you may use a program
      # like wev.
      #
      # "Mod" is a special modifier equal to Super when running on a TTY, and to Alt
      # when running as a winit window.
      #
      # Most actions that you can bind here can also be invoked programmatically with
      # `niri msg action do-something`.

      # Mod-Shift-/, which is usually the same as Mod-?,
      # shows a list of important hotkeys.
      "Mod+Shift+Ssharp".action = show-hotkey-overlay;

      # Suggested binds for running programs: terminal, app launcher, screen locker.
      "Mod+T" = {
        hotkey-overlay = {
          title = "Open a Terminal: kitty";
        };
        action = spawn "kitty";
      };
      "Mod5+T".action = spawn "kitty";
      "Mod+D" = {
        hotkey-overlay = {
          title = "Run an Application: rofi";
        };
        action = spawn-sh "rofi -show drun -theme ~/.config/rofi/launchers/type-7/style-custom.rasi";
      };
      "Super+L" = {
        hotkey-overlay = {
          title = "Lock the Screen: swaylock";
        };
        action = spawn "swaylock";
      };

      # Example volume keys mappings for PipeWire & WirePlumber.
      # The allow-when-locked=true property makes them work even when the session is locked.
      # Using spawn-sh allows to pass multiple arguments together with the command.
      XF86AudioRaiseVolume = {
        allow-when-locked = true;
        action = spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+";
      };
      XF86AudioLowerVolume = {
        allow-when-locked = true;
        action = spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-";
      };
      XF86AudioMute = {
        allow-when-locked = true;
        action = spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
      };
      XF86AudioMicMute = {
        allow-when-locked = true;
        action = spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
      };

      # TODO:
      # Example media keys mapping using playerctl.
      # This will work with any MPRIS-enabled media player.
      XF86AudioPlay = {
        allow-when-locked = true;
        action = spawn-sh "playerctl play-pause";
      };
      XF86AudioStop = {
        allow-when-locked = true;
        action = spawn-sh "playerctl stop";
      };
      XF86AudioPrev = {
        allow-when-locked = true;
        action = spawn-sh "playerctl previous";
      };
      XF86AudioNext = {
        allow-when-locked = true;
        action = spawn-sh "playerctl next";
      };

      # Example brightness key mappings for brightnessctl.
      # You can use regular spawn with multiple arguments too (to avoid going through "sh"),
      # but you need to manually put each argument in separate "" quotes.
      XF86MonBrightnessUp = {
        allow-when-locked = true;
        action = spawn "brightnessctl" "--class=backlight" "set" "+2%";
      };
      XF86MonBrightnessDown = {
        allow-when-locked = true;
        action = spawn "brightnessctl" "--class=backlight" "set" "2%-";
      };

      # Open/close the Overview: a zoomed-out view of workspaces and windows.
      # You can also move the mouse into the top-left hot corner,
      # or do a four-finger swipe up on a touchpad.
      "Mod+O" = {
        repeat = false;
        action = toggle-overview;
      };
      "Mod+Space" = {
        repeat = false;
        action = toggle-overview;
      };

      "Mod+Q" = {
        repeat = false;
        action = close-window;
      };

      "Mod+Left".action = focus-column-left;
      "Mod+Down".action = focus-window-down;
      "Mod+Up".action = focus-window-up;
      "Mod+Right".action = focus-column-right;

      "Mod+Shift+Left".action = move-column-left;
      "Mod+Shift+Down".action = move-window-down;
      "Mod+Shift+Up".action = move-window-up;
      "Mod+Shift+Right".action = move-column-right;

      # Alternative commands that move across workspaces when reaching
      # the first or last window in a column.
      # Mod+J     { focus-window-or-workspace-down; }
      # Mod+K     { focus-window-or-workspace-up; }
      # Mod+Ctrl+J     { move-window-down-or-to-workspace-down; }
      # Mod+Ctrl+K     { move-window-up-or-to-workspace-up; }

      "Mod+Home".action = focus-column-first;
      "Mod+End".action = focus-column-last;
      "Mod+Shift+Home".action = move-column-to-first;
      "Mod+Shift+End".action = move-column-to-last;

      "Mod+Ctrl+Left".action = focus-monitor-left;
      "Mod+Ctrl+Down".action = focus-monitor-down;
      "Mod+Ctrl+Up".action = focus-monitor-up;
      "Mod+Ctrl+Right".action = focus-monitor-right;

      "Mod+Shift+Ctrl+Left".action = move-column-to-monitor-left;
      "Mod+Shift+Ctrl+Down".action = move-column-to-monitor-down;
      "Mod+Shift+Ctrl+Up".action = move-column-to-monitor-up;
      "Mod+Shift+Ctrl+Right".action = move-column-to-monitor-right;

      # Alternatively, there are commands to move just a single window:
      # Mod+Shift+Ctrl+Left  { move-window-to-monitor-left; }
      # ...

      # And you can also move a whole workspace to another monitor:
      # Mod+Shift+Ctrl+Left  { move-workspace-to-monitor-left; }
      # ...
      "Mod+Alt+Left".action = move-workspace-to-monitor-left;
      "Mod+Alt+Down".action = move-workspace-to-monitor-down;
      "Mod+Alt+Up".action = move-workspace-to-monitor-up;
      "Mod+Alt+Right".action = move-workspace-to-monitor-right;

      "Mod+Page_Down".action = focus-workspace-down;
      "Mod+Tab".action = focus-workspace-down;
      "Mod+Page_Up".action = focus-workspace-up;
      "Mod+Shift+Tab".action = focus-workspace-up;
      "Mod+Shift+Page_Down".action = move-column-to-workspace-down;
      "Mod+Shift+Page_Up".action = move-column-to-workspace-up;

      # Alternatively, there are commands to move just a single window:
      # Mod+Ctrl+Page_Down { move-window-to-workspace-down; }
      # ...

      # TODO: figure out how this "flows"
      "Mod+Ctrl+Page_Down".action = move-workspace-down;
      "Mod+Ctrl+Page_Up".action = move-workspace-up;

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

      # You can refer to workspaces by index. However, keep in mind that
      # niri is a dynamic workspace system, so these commands are kind of
      # "best effort". Trying to refer to a workspace index bigger than
      # the current workspace count will instead refer to the bottommost
      # (empty) workspace.
      #
      # For example, with 2 workspaces + 1 empty, indices 3, 4, 5 and so on
      # will all refer to the 3rd workspace.
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
      #"Mod+Ctrl+1".action = "move-column-to-workspace 1";
      #"Mod+Ctrl+2".action = "move-column-to-workspace 2";
      #"Mod+Ctrl+3".action = "move-column-to-workspace 3";
      #"Mod+Ctrl+4".action = "move-column-to-workspace 4";
      #"Mod+Ctrl+5".action = "move-column-to-workspace 5";
      #"Mod+Ctrl+6".action = "move-column-to-workspace 6";
      #"Mod+Ctrl+7".action = "move-column-to-workspace 7";
      #"Mod+Ctrl+8".action = "move-column-to-workspace 8";
      #"Mod+Ctrl+9".action = "move-column-to-workspace 9";

      # Alternatively, there are commands to move just a single window:
      # Mod+Ctrl+1 { move-window-to-workspace 1; }

      # Switches focus between the current and the previous workspace.
      # Mod+Tab { focus-workspace-previous; }

      # The following binds move the focused window in and out of a column.
      # If the window is alone, they will consume it into the nearby column to the side.
      # If the window is already in a column, they will expel it out.
      "Mod+Udiaeresis".action = consume-or-expel-window-left; # Ü
      "Mod+Plus".action = consume-or-expel-window-right;

      # TODO: play around with these
      # Consume one window from the right to the bottom of the focused column.
      "Mod+Comma".action = consume-window-into-column;
      # Expel the bottom window from the focused column to the right.
      "Mod+Period".action = expel-window-from-column;

      "Mod+R".action = switch-preset-column-width;
      # Cycling through the presets in reverse order is also possible.
      # Mod+R { switch-preset-column-width-back; }
      "Mod+Shift+R".action = switch-preset-window-height;
      "Mod+Ctrl+R".action = reset-window-height;
      "Mod+F".action = maximize-column;
      "Mod+Shift+F".action = fullscreen-window;

      # Expand the focused column to space not taken up by other fully visible columns.
      # Makes the column "fill the rest of the space".
      # TODO: Mod+Ctrl+F { expand-column-to-available-width; }

      "Mod+C".action = center-column;

      # Center all fully visible columns on screen.
      "Mod+Ctrl+C".action = center-visible-columns;

      # Finer width adjustments.
      # This command can also:
      # * set width in pixels: "1000"
      # * adjust width in pixels: "-5" or "+5"
      # * set width as a percentage of screen width: "25%"
      # * adjust width as a percentage of screen width: "-10%" or "+10%"
      # Pixel sizes use logical, or scaled, pixels. I.e. on an output with scale 2.0,
      # set-column-width "100" will make the column occupy 200 physical screen pixels.
      "Mod+Minus".action = set-column-width "-10%";
      "Mod+Equal".action = set-column-width "+10%";

      # TODO: howto on german keyboard?
      # Finer height adjustments when in column with other windows.
      "Mod+Shift+Minus".action = set-window-height "-10%";
      "Mod+Shift+Equal".action = set-window-height "+10%";

      # Move the focused window between the floating and the tiling layout.
      "Mod+V".action = toggle-window-floating;
      "Mod+Shift+V".action = switch-focus-between-floating-and-tiling;

      # Toggle tabbed column display mode.
      # Windows in this column will appear as vertical tabs,
      # rather than stacked on top of each other.
      "Mod+W".action = toggle-column-tabbed-display;

      # Actions to switch layouts.
      # Note: if you uncomment these, make sure you do NOT have
      # a matching layout switch hotkey configured in xkb options above.
      # Having both at once on the same hotkey will break the switching,
      # since it will switch twice upon pressing the hotkey (once by xkb, once by niri).
      # Mod+Space       { switch-layout "next"; }
      # Mod+Shift+Space { switch-layout "prev"; }

      "Print".action.screenshot = [ ];
      "Mod+P".action.screenshot = [ ];
      "Ctrl+Print".action.screenshot-screen = [ ];
      "Alt+Print".action.screenshot-window = [ ];

      # Applications such as remote-desktop clients and software KVM switches may
      # request that niri stops processing the keyboard shortcuts defined here
      # so they may, for example, forward the key presses as-is to a remote machine.
      # It's a good idea to bind an escape hatch to toggle the inhibitor,
      # so a buggy application can't hold your session hostage.
      #
      # The allow-inhibiting=false property can be applied to other binds as well,
      # which ensures niri always processes them, even when an inhibitor is active.
      "Mod+Shift+Escape" = {
        allow-inhibiting = false;
        action = toggle-keyboard-shortcuts-inhibit;
      };

      # The quit action will show a confirmation dialog to avoid accidental exits.
      "Mod+Shift+E".action = quit;
      "Mod+Shift+Q".action = quit;
      "Ctrl+Alt+Delete".action = quit;

      # Powers off the monitors. To turn them back on, do any input like
      # moving the mouse or pressing any other key.
      "Mod+Shift+P".action = power-off-monitors;

      "Mod+Ctrl+F".action = spawn-sh "firefox -P";
      "Mod+Ctrl+B".action =
        spawn-sh "google-chrome-stable --ozone-platform-hint=auto --enable-features=WebRTCPipeWireCapturer; sleep 1; ${lib.getExe pkgs.scripts.niri-consume-stack}";
      "Mod+Ctrl+M".action = spawn-sh "Telegram";
      "Mod+Ctrl+S".action =
        spawn-sh "slack --ozone-platform=wayland --enable-features=WebRTCPipeWireCapturer";

      "Mod+Shift+C".action = spawn (lib.getExe pkgs.scripts.niri-consume-stack);

      "Mod+Escape" = {
        hotkey-overlay = {
          title = "Run an Application: rofi";
        };
        action = spawn-sh "rofi -show drun -theme ~/.config/rofi/launchers/type-7/style-custom.rasi";
      };
      #"Menu" = {
      #  hotkey-overlay = { title = "Run an Application: rofi"; };
      #  action = spawn-sh "rofi -show drun -theme ~/.config/rofi/launchers/type-7/style-custom.rasi";
      #};

      "Mod+L".action = spawn "swaylock";
      "Mod+F1".action = spawn-sh "~/.config/hypr/scripts/show_keybinds.sh";
      "Mod+Shift+X".action = spawn-sh "hyprpicker -a -n";

      "Mod+Shift+W".action = spawn-sh "$lib.getExe script-shuffle-wallpaper}";

      "XF86KbdBrightnessUp".action = spawn-sh "brightnessctl -d '*::kbd_backlight' set +1";
      "XF86KbdBrightnessDown".action = spawn-sh "brightnessctl -d '*::kbd_backlight' set 1-";
      "Mod+K".action = spawn-sh "brightnessctl -d '*::kbd_backlight' set 1+";
      "Mod+Shift+K".action = spawn-sh "brightnessctl -d '*::kbd_backlight' set 1-";

      "Mod+Return".action = fullscreen-window;
      "Mod+Shift+Return".action = fullscreen-window;

    };
  };
}
