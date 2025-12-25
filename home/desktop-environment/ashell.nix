{
  pkgs,
  inputs,
  lib,
  config,
  ...
}:
let
  tomlinnix = {
    log_level = "warn";
    outputs = "All";
    position = "Top";
    appLauncher_cmd = "rofi -show drun -theme ~/.config/rofi/launchers/type-7/style-custom.rasi";
    clipboard_cmd = "cliphist-rofi-img | wl-copy";
    truncate_title_after_length = 50;

    modules = {
      left = [
        [
          "AppLauncher"
          "Updates"
          "Sleepy"
        ]
        "Tray"
        "WindowTitle"
      ];
      center = [ "Workspaces" ];
      right = [
        "MediaPlayer"
        "Qr-Scan"
        "ColorPicker"
        "Clipboard"
      ]
      ++ lib.optionals config.custom.hardware.enableNvidia [ "GPU" ]
      ++ [
        "SystemInfo"
        "Swaync"
        [
          "Clock"
          "Privacy"
          "Settings"
        ]
      ];
    };

    CustomModule = [
      {
        name = "Sleepy";

        icon = "";
        command = "${lib.getExe (
          pkgs.writeShellApplication {
            name = "redshift-toggle";
            runtimeInputs = [
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
      }
      {
        name = "GPU";
        icon = "󰈸";
        icons."suspended" = "󱜢";
        command = "";
        listen_cmd = "${lib.getExe (
          pkgs.writeShellApplication {
            name = "gpu-status-listener";
            text = ''
              while true; do
                status="$(supergfxctl -S)"
                echo "{\"alt\":\"$status\", \"text\":\"$status\"}"
                sleep 60
              done
            '';
          }
        )}";
      }
      {
        name = "Qr-Scan";
        icon = "󰐲";
        command = lib.getExe pkgs.scripts.screenshot-area-scan-qr;
      }
      {
        name = "ColorPicker";
        icon = "";
        command = "${lib.getExe pkgs.hyprpicker} --autocopy";
      }
      {
        name = "Swaync";
        icon = "";
        icons."dnd.*" = "";
        alert = ".*notification";
        listen_cmd = "swaync-client -swb";
        command = "swaync-client -t -sw";
      }
    ];

    updates = {
      check_cmd = "checkupdates; paru -Qua";
      update_cmd = "alacritty -e bash -c \"paru; echo Done - Press enter to exit; read\" &";
    };

    workspaces = {
      visibility_mode = "All";
      enable_workspace_filling = false;
    };

    system = {
      cpu_warn_threshold = 60;
      cpu_alert_threshold = 80;
      mem_warn_threshold = 70;
      mem_alert_threshold = 85;
      temp_warn_threshold = 60;
      temp_alert_threshold = 80;
    };

    clock = {
      format = "%a %d %b %R";
    };

    media_player = {
      max_title_length = 20;
    };

    settings = {
      lock_cmd = "swaylock &";
      audio_sinks_more_cmd = "pavucontrol -t 3";
      audio_sources_more_cmd = "pavucontrol -t 4";
      wifi_more_cmd = "uswm app iwctl";
      vpn_more_cmd = "nm-connection-editor";
      bluetooth_more_cmd = "uwsm app blueman-manager";
      remove_airplane_btn = true;
      CustomButton = [
        {
          name = "Terminal";
          icon = "🖥️";
          command = "${lib.getExe pkgs.kitty}";
        }
      ];
    };

    appearance = {
      style = "Islands";
      opacity = 0.8;
      success_color = "#a6e3a1";
      danger_color = "#f38ba8";
      workspace_colors = [ "#dddddd" ];
      menu = {
        opacity = 0.7;
        backdrop = 0.3;
      };
    };
  };

  toToml = pkgs.formats.toml { };
in
{
  xdg.configFile."ashell/config.toml".source = toToml.generate "ashell-config" tomlinnix;

  home.packages = [
    pkgs.ashell
    pkgs.sunsetr
  ];

  systemd.user.services.ashell = {
    Unit = {
      Description = "ashell status bar";
      After = [ config.wayland.systemd.target ];
    };

    Service = {
      ExecStart = "${lib.getExe pkgs.ashell}";
      Restart = "on-failure";
    };

    Install.WantedBy = [ config.wayland.systemd.target ];
  };
}
