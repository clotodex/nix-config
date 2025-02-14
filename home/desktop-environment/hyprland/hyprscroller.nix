{ pkgs }:
{
  scroller_toggle = pkgs.writeShellApplication {
    name = "hyprscroller-toggle";
    runtimeInputs = [
      pkgs.fzf
      pkgs.gnugrep
    ];
    text = ''
      MODE_FILE="/tmp/hyprland_scroller_mode"

      current_mode=$(cat "$MODE_FILE")

      if [[ "$current_mode" =~ "Row" ]]; then
          hyprctl dispatch -- scroller:setmode column
          notify-send -a "t1" -r 91190 -t 2200 "Column mode active."
      elif [[ "$current_mode" =~ "Column" ]]; then
        hyprctl dispatch -- scroller:setmode row
        notify-send -a "t1" -r 91190 -t 2200  "Row mode active."
      else
          notify-send -a "t1" -r 91190 -t 2200  "Error: Could not detect current mode."
      fi
    '';
  };
  scroller_listen = pkgs.writeShellApplication {
    name = "hyprscroller-listen";
    runtimeInputs = [ pkgs.socat ];
    text = ''
      MODE_FILE="/tmp/hyprland_scroller_mode"

      function handle {
        if [[ ''${1:0:8} == "scroller" ]]; then
          if [[ ''${1:10:9} == "mode, row" ]]; then
              echo "Row" > "$MODE_FILE"
          elif [[ ''${1:10:12} == "mode, column" ]]; then
              echo "Column" > "$MODE_FILE"
          #else
              #echo "" > "$MODE_FILE"
          fi
          hyprctl dispatch submap reset && pkill -SIGRTMIN+8 waybar # update the widget on waybar
        fi
      }
      echo "" > "$MODE_FILE"

      socat - "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while read -r line; do handle "$line"; done
    '';
  };
  scroller_read = pkgs.writeShellApplication {
    name = "hyprscroller-read";
    text = ''
      MODE_FILE="/tmp/hyprland_scroller_mode"

      current_mode=$(cat "$MODE_FILE")

      if [[ "$current_mode" == "Row" ]]; then
          icon="Row"
          percent=0
          class="mode-row"
      elif [[ "$current_mode" == "Column" ]]; then
          icon="Column"
          percent=100
          class="mode-column"
      else
          icon="Row"
          percent=0
          class=""
      fi

      echo "{\"text\":\"$icon\", \"tooltip\":\"Scroller Mode: $current_mode\", \"class\":\"$class\",\"percentage\": $percent}"
    '';
  };
}
