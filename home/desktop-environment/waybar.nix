{
  lib,
  pkgs,
  ...
}:
let
  scroller_scripts = import ./hyprland/hyprscroller.nix { inherit pkgs; };
in
{
  home.packages = with pkgs; [
    waybar-custom-modules
  ];

  # TODO: scripts for turning tlp into power mode or performance mode - no matter if AC or BAT

  programs.waybar = {
    enable = true;
    # Started via hyprland to ensure it restarts properly with hyprland
    systemd.enable = false;
    style = ./waybar-style.css;
    settings.main = {
      layer = "top";
      margin-bottom = 0;
      margin-left = 0;
      margin-right = 0;
      spacing = 0;
      height = 28;

      modules-left = [
        "hyprland/submap"
        "privacy"

        "custom/hyprshade"
        #"custom/fwupdates"
        "custom/hypridle"
        "custom/cpuline"
        "custom/cpufreqline"
        "custom/memline"
        "custom/waybarthemes"
        "custom/hyprscroller"
        "group/quicklinks"
        "hyprland/window"
        #"custom/whisper_overlay"
      ];
      modules-center = [
        "hyprland/workspaces"
      ];
      modules-right = [
        "group/hardware"
        "custom/scan_qr"
        "custom/pick_color"
        #"custom/screencast"
        #"custom/gpuscreenrecorder"

        #SPACER

        #"brightness"
        #"pulseaudio#source"
        "wireplumber"

        "network"
        "bluetooth"
        #"custom/cliphist"
        "battery"
        "tray"
        "custom/notification"
        "clock"
      ];

      "custom/scan_qr" = {
        tooltip = true;
        tooltip-format = "Scan QR Code";
        format = "󰐲";
        on-click = lib.getExe pkgs.scripts.screenshot-area-scan-qr;
      };

      "custom/pick_color" = {
        tooltip = true;
        tooltip-format = "Pick color";
        format = "";
        on-click = "${lib.getExe pkgs.hyprpicker} --autocopy";
      };

      "custom/notification" = {
        tooltip = false;
        format = "{icon} {}";
        format-icons = {
          notification = "<span foreground='red'><sup></sup></span>";
          none = "";
          dnd-notification = "<span foreground='red'><sup></sup></span>";
          dnd-none = "";
          inhibited-notification = "<span foreground='red'><sup></sup></span>";
          inhibited-none = "";
          dnd-inhibited-notification = "<span foreground='red'><sup></sup></span>";
          dnd-inhibited-none = "";
        };
        return-type = "json";
        exec = "${pkgs.swaynotificationcenter}/bin/swaync-client -swb";
        on-click = "${pkgs.swaynotificationcenter}/bin/swaync-client -t -sw";
        on-click-right = "${pkgs.swaynotificationcenter}/bin/swaync-client -d -sw";
        on-click-middle = "${pkgs.swaynotificationcenter}/bin/swaync-client --close-all";
        escape = true;
      };

      #"custom/whisper_overlay" = {
      #  tooltip = true;
      #  format = "{icon}";
      #  format-icons = {
      #    disconnected = "<span foreground='gray'></span>";
      #    connected = "<span foreground='#4ab0fa'></span>";
      #    connected-active = "<span foreground='red'></span>";
      #  };
      #  return-type = "json";
      #  exec = "${lib.getExe pkgs.whisper-overlay} waybar-status";
      #  on-click-right = lib.getExe (pkgs.writeShellApplication {
      #    name = "toggle-realtime-stt-server";
      #    runtimeInputs = [
      #      pkgs.systemd
      #      pkgs.libnotify
      #    ];
      #    text = ''
      #      if systemctl --user is-active --quiet realtime-stt-server; then
      #        systemctl --user stop realtime-stt-server.service
      #        notify-send "Stopped realtime-stt-server" "⛔ Stopped" --transient || true
      #      else
      #        systemctl --user start realtime-stt-server.service
      #        notify-send "Started realtime-stt-server" "✅ Started" --transient || true
      #      fi
      #    '';
      #  });
      #  escape = true;
      #};

      privacy = {
        icon-spacing = 4;
        icon-size = 18;
        transition-duration = 250;
        modules = [
          {
            type = "screenshare";
            tooltip = true;
            tooltip-icon-size = 24;
          }
          {
            type = "audio-out";
            tooltip = true;
            tooltip-icon-size = 24;
          }
          {
            type = "audio-in";
            tooltip = true;
            tooltip-icon-size = 24;
          }
        ];
      };

      wireplumber = {
        #format = "<tt>{icon} {volume}%</tt>";
        #format-muted = "<tt> {volume}%</tt>";
        format = "{icon} {volume}%";
        format-muted = " {volume}%";
        #format-icons = ["" ""];
        format-icons = [
          ""
          ""
          ""
        ];
        on-click = "hyprctl dispatch exec \"[float;pin;move 60% 0%;size 40% 50%;noborder]\" ${lib.getExe pkgs.pwvucontrol}";
        on-click-middle = "${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 100%";
        on-click-right = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        on-scroll-down = "${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%+";
        on-scroll-up = "${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%-";
      };

      #"pulseaudio#source" = {
      #  format = "{format_source}";
      #  format-source = "<tt> {volume}%</tt>";
      #  format-source-muted = "<tt> {volume}%</tt>";
      #  on-click = "${pkgs.hyprland}/bin/hyprctl dispatch exec \"[float]\" ${lib.getExe pkgs.helvum}";
      #  on-click-middle = "${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 100%";
      #  on-click-right = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
      #  on-scroll-down = "${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 1%+";
      #  on-scroll-up = "${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 1%-";
      #};

      "hyprland/workspaces" = {
        format = "{icon}";
        format-icons.urgent = "";
        sort-by = "id";
        on-click = "activate";
        active-only = false;
        all-outputs = true; # TODO: maybe false, lets see
      };

      clock = {
        interval = 10;
        format = "{:%H:%M:%S}";
        format-alt = "{:%A, %B %d, %Y (%R)}";
        tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        #tooltip-format = "<tt><span size='16pt' font='JetBrains Mono'>{calendar}</span></tt>";
        calendar = {
          mode = "year";
          mode-mon-col = 4;
          weeks-pos = "right";
          on-scroll = 1;
          on-click-right = "mode";
          format = {
            months = "<span color='#ffead3'><b>{}</b></span>";
            days = "<span color='#ecc6d9'><b>{}</b></span>";
            weeks = "<span color='#99ffdd'><b>W{}</b></span>";
            weekdays = "<span color='#ffcc66'><b>{}</b></span>";
            today = "<span bgcolor='#ff6699' color='#000000'><b><u>{}</u></b></span>";
          };
          actions = {
            on-click-right = "mode";
            on-click-forward = "tz_up";
            on-click-backward = "tz_down";
            on-scroll-up = "shift_up";
            on-scroll-down = "shift_down";
          };
        };
      };

      network = {
        interval = 5;
        format-ethernet = "󰈀  {ipaddr}/{cidr} <span color='#ffead3'>↓ {bandwidthDownBytes}</span> <span color='#ecc6d9'>↑ {bandwidthUpBytes}</span>";
        format-disconnected = "⚠  Disconnected";
        tooltip-format = "↑ {bandwidthUpBytes}\n↓ {bandwidthDownBytes} via {gwaddri}";
        format = "{ifname}";
        format-wifi = "   {signalStrength}%";
        tooltip-format-wifi = "   {essid} ({signalStrength}%)";
        tooltip-format-ethernet = "  {ifname} ({ipaddr}/{cidr})";
        tooltip-format-disconnected = "Disconnected";
        max-length = 50;
        on-click = "kitty -e iwctl";
      };

      bluetooth = {
        format = "  {status} ";
        format-connected = " {device_alias}";
        format-connected-battery = " {device_alias} {device_battery_percentage}%";
        tooltip-format = "{controller_alias}\t{controller_address}\n\n{num_connections} connected";
        tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{num_connections} connected\n\n{device_enumerate}";
        tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
        tooltip-format-enumerate-connected-battery = "{device_alias}\t{device_address}\t{device_battery_percentage}%";
      };

      memory = {
        interval = 3;
        format = "  {percentage}%";
        states = {
          warning = 70;
          critical = 90;
        };
      };

      cpu = {
        interval = 3;
        format = "  {usage}%";
        tooltip-format = "{usage}";
      };

      #"hyprland/window" = {
      #  rewrite = [
      #    "(.*) - Brave= "$1";
      #    "(.*) - Chromium= "$1";
      #    "(.*) - Brave Search= "$1";
      #    "(.*) - Outlook= "$1";
      #    "(.*) Microsoft Teams= "$1"
      #  };
      #  "separate-outputs= true
      #};

      "custom/hyprscroller" = {
        exec = "${lib.getExe scroller_scripts.scroller_read}";
        return-type = "json";
        interval = "once";
        signal = 8;
        on-click = "hyprctl dispatch submap reset && pkill -SIGRTMIN+8 waybar";
        format = "{icon}";
        format-icons = [
          ""
          ""
        ];
      };

      # TODO: change to shell scripts
      "custom/hyprshade" = {
        format = "";
        on-click = "${lib.getExe (
          pkgs.writeShellApplication {
            name = "hyprshade-toggle";
            runtimeInputs = [
              # hyprshade
              pkgs.libnotify
            ];
            text = ''
              if [ -z "$(hyprshade current)" ] ;then
                  echo ":: hyprshade is not running"
                  hyprshade on blue-light-filter
                  notify-send "Hyprshade activated" "with $(hyprshade current)"
                  echo ":: hyprshade started with $(hyprshade current)"
              else
                  notify-send "Hyprshade deactivated"
                  echo ":: Current hyprshade $(hyprshade current)"
                  echo ":: Switching hyprshade off"
                  hyprshade off
              fi
            '';
          }
        )}";
        on-click-right = "${lib.getExe (
          pkgs.writeShellApplication {
            name = "hyprshade-toggle-menu";
            runtimeInputs = [
              # hyprshade
              pkgs.rofi
              pkgs.libnotify
              pkgs.gawk
            ];
            text = ''
              # Open rofi to select the Hyprshade filter for toggle
              options="$(hyprshade ls)\noff"

              # Open rofi
              choice=$(echo -e "$options" | rofi -dmenu -replace -config ~/dotfiles/rofi/config-hyprshade.rasi -i -no-show-icons -l 4 -width 30 -p "Hyprshade")
              if [ -n "$choice" ] ;then
                  # strip choice
                  choice=$(echo "$choice" | awk '{print $1}')
                  notify-send "Changing Hyprshade to $choice"
                  hyprshade_filter=$choice
              fi

              # Toggle Hyprshade
              if [ "$hyprshade_filter" != "off" ] ;then
                  if [ -z "$(hyprshade current)" ] ;then
                      echo ":: hyprshade is not running"
                      hyprshade on "$hyprshade_filter"
                      notify-send "Hyprshade activated" "with $(hyprshade current)"
                      echo ":: hyprshade started with $(hyprshade current)"
                  else
                      notify-send "Hyprshade deactivated"
                      echo ":: Current hyprshade $(hyprshade current)"
                      echo ":: Switching hyprshade off"
                      hyprshade off
                  fi
              else
                  hyprshade off
                  echo ":: hyprshade turned off"
              fi
            '';
          }
        )}";
        tooltip = false;
      };

      "custom/hypridle" = {
        format = "";
        return-type = "json";
        escape = true;
        exec-on-event = true;
        interval = 30;
        exec = "~/projects/development/linux/hyprdot/hypr/scripts/hypridle.sh status";
        on-click = "~/projects/development/linux/hyprdot/hypr/scripts/hypridle.sh toggle";
        on-click-right = "hyprlock";
      };

      #"custom/fwupdates= {
      #  format= "   {}";
      #  tooltip-format= "{}";
      #  escape= true;
      #  return-type= "json";
      #  exec= "~/.config/hypr/scripts/updates.sh";
      #  restart-interval= 60;
      #  on-click= "kitty --hold sudo /home/clotodex/.config/hypr/scripts/update_script.sh";
      #  tooltip= false
      #};

      "custom/chatgpt" = {
        format = "";
        on-click = "google-chrome --app=https://chat.openai.com";
        tooltip = false;
      };

      "custom/appmenu" = {
        format = "Apps";
        on-click = "rofi -show drun -replace";
        on-click-right = "~/.config/hypr/scripts/keybindings.sh";
        tooltip = false;
      };

      "custom/cpuline" = {
        format = "{} ";
        exec = "waybar-cpu -i 5s";
        return-type = "json";
      };
      "custom/cpufreqline" = {
        format = "{} ";
        exec = "waybar-cpufreq -i 5s";
        return-type = "json";
      };
      "custom/memline" = {
        format = "{} ";
        exec = "waybar-mem -i 5s";
        return-type = "json";
      };

      tray = {
        # icon-size= 21;
        spacing = 10;
      };

      "custom/system" = {
        format = "";
        tooltip = false;
      };

      temperature = {
        # "thermal-zone= 2;
        # "hwmon-path= "/sys/class/hwmon/hwmon2/temp1_input";
        # "critical-threshold= 80;
        # "format-critical= "{temperatureC}°C ";
        format = " {temperatureC}°C";
      };

      disk = {
        interval = 30;
        format = "D {percentage_used}% ";
        path = "/";
        on-click = "kitty -e duf";
      };

      "group/hardware" = {
        orientation = "inherit";
        drawer = {
          transition-duration = 300;
          children-class = "not-memory";
          transition-left-to-right = false;
        };
        modules = [
          "custom/system"
          "disk"
          "cpu"
          "memory"
          "temperature"
        ];
      };

      "group/quicklinks" = {
        orientation = "horizontal";
        modules = [ "custom/chatgpt" ];
      };

      battery = {
        states = {
          full = 100;
          good = 90;
          warning = 30;
          critical = 15;
        };
        format = "{icon}   {capacity}%";
        format-charging = "  {capacity}%";
        format-plugged = "  {capacity}%";
        format-alt = "{icon}  {time}";
        # "format-good= "", // An empty format will hide the module
        # "format-full= "";
        format-icons = [
          " "
          " "
          " "
          " "
          " "
        ];
      };

      #pulseaudio = {
      #  # "scroll-step= 1, // %, can be a float
      #  format = "{icon}  {volume}%";
      #  format-bluetooth = "{volume}% {icon} {format_source}";
      #  format-bluetooth-muted = " {icon} {format_source}";
      #  format-muted = " {format_source}";
      #  format-source = "{volume}% ";
      #  format-source-muted = "";
      #  format-icons = {
      #    headphone = "";
      #    hands-free = " ";
      #    headset = "";
      #    phone = "";
      #    portable = "";
      #    car = "";
      #    default = ["" " " " "];
      #    speaker = ["" " " " "];
      #    #speaker = "S";
      #    hdmi = "H";
      #    hifi = "I";
      #  };
      #  on-click = "pavucontrol";
      #};

      bluetooth = {
        format-disabled = "";
        format-off = "";
        interval = 30;
        on-click = "blueman-manager";
        format-no-controller = "";
      };

      user = {
        format = "{user}";
        interval = 60;
        icon = false;
      };

      idle_inhibitor = {
        format = "{icon}";
        tooltip = true;
        format-icons = {
          activated = "";
          deactivated = "";
        };
        on-click-right = "hyprlock";
      };
    };
  };
}
