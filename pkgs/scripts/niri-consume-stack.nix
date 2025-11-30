{
  writeShellApplication,
  niri,
  jq,
  ...
}:
writeShellApplication {
  name = "niri-consume-stack";
  runtimeInputs = [
    niri
    jq
  ];
  text = ''
    # Parse optional flags: --quiet/-q, --sleep <seconds>, --max-iterations <n>
    quiet=0
    sleep_interval=0
    max_iterations=10

    usage() {
      cat <<'USAGE' >&2
Usage: niri-consume-stack [OPTIONS]

Options:
  -q, --quiet                 Suppress output
  -s, --sleep <seconds>       Sleep interval between steps (great for debugging) (default 0)
  -m, --max-iterations <n>    Maximum reconcile iterations (default 10)
  -h, --help                  Show this help message

Example:
  niri-consume-stack --sleep 0.1 --max-iterations 20
USAGE
    }

    while [ "$#" -gt 0 ]; do
      case "$1" in
        --quiet|-q)
          quiet=1
          shift
          ;;
        --sleep|-s)
          if [ -z "$2" ]; then
            usage
            exit 1
          fi
          sleep_interval="$2"
          shift 2
          ;;
        --max-iterations|-m)
          if [ -z "$2" ]; then
            usage
            exit 1
          fi
          max_iterations="$2"
          shift 2
          ;;
        --help|-h)
          usage
          exit 0
          ;;
        --)
          shift
          break
          ;;
        -*)
          # unknown short/long option
          usage
          exit 1
          ;;
        *)
          # stop parsing on first non-flag
          break
          ;;
      esac
    done

    # Logging helpers
    log() {
      if [ "$quiet" -ne 1 ]; then
        echo "$@"
      fi
    }

    # Call sleep only when configured to a non-zero interval (zero is a no-op)
    maybe_sleep() {
      if [ -z "$sleep_interval" ] || [ "$sleep_interval" = "0" ]; then
        return
      fi
      sleep "$sleep_interval"
    }

    # Get information about all windows
    get_windows() {
    	niri msg -j windows
    }

    # Get windows of the same class in the same workspace but different column
    get_windows_to_merge() {
    	local class=$1
    	local workspace=$2
    	local target_column=$3
    	echo "$windows_json" | jq -c "
            [.[] | select(
                .app_id == \"$class\" and
                .workspace_id == $workspace and
                .layout.pos_in_scrolling_layout[0] != $target_column
            )]
            | sort_by(.layout.pos_in_scrolling_layout[0], .layout.pos_in_scrolling_layout[1])
            | .[]
        "
    }

    # Safety counters
    iteration=0
    previous_count=-1

    # Reconcile loop
    while [ $iteration -lt "$max_iterations" ]; do
    	iteration=$((iteration + 1))

    	# Refresh window data
    	windows_json=$(get_windows)

    	# Get focused window info (this is our target)
    	focused=$(echo "$windows_json" | jq '.[] | select(.is_focused == true)')
    	target_id=$(echo "$focused" | jq -r '.id')
    	target_class=$(echo "$focused" | jq -r '.app_id')
    	target_workspace=$(echo "$focused" | jq -r '.workspace_id')
    	target_column=$(echo "$focused" | jq -r '.layout.pos_in_scrolling_layout[0]')

    	if [ -z "$target_id" ]; then
    		log "Error: No focused window found"
    		exit 1
    	fi

    	log "Target: ID=$target_id, class=$target_class, column=$target_column"

    	# Get windows that need to be merged
    	windows_to_merge=$(get_windows_to_merge "$target_class" "$target_workspace" "$target_column")

    	# Count non-empty lines properly
    	if [ -z "$windows_to_merge" ]; then
    		merge_count=0
    	else
    		merge_count=$(echo "$windows_to_merge" | wc -l)
    	fi

    	if [ "$merge_count" -eq 0 ]; then
    		log "All windows merged! (iteration $iteration)"
    		break
    	fi

    	# Check if we're making progress
    	if [ "$previous_count" -eq "$merge_count" ]; then
    		log "Error: No progress made in iteration $iteration (still $merge_count windows to merge)"
    	fi
    	previous_count=$merge_count

    	log "Iteration $iteration: $merge_count windows left to merge"

    	# Get next window to merge
    	next_window=$(echo "$windows_to_merge" | head -n 1)
    	next_id=$(echo "$next_window" | jq -r '.id')
    	next_column=$(echo "$next_window" | jq -r '.layout.pos_in_scrolling_layout[0]')

    	log "  Target window: ID=$target_id, column=$target_column"
    	log "  Next window to merge: ID=$next_id, column=$next_column"

    	if [ -z "$next_id" ] || [ "$next_id" = "null" ]; then
    		log "Error: Could not get next window to merge"
    		exit 1
    	fi

    	log "  Moving window ID=$next_id from column $next_column to column $target_column"
        distance=$(( target_column - next_column ))
    	abs_distance=''${distance#-}
    	log "  Distance to target column: $distance"

    	# Focus the window to merge
    	niri msg action focus-window --id "$next_id"
    	sleep "$sleep_interval"
    	if [ "$abs_distance" -gt 1 ]; then
    		log "  Note: Window is more than one column away; will move it step by step"
    		for _ in $(seq 1 $((abs_distance - 1))); do
    			if [ "$distance" -gt 0 ]; then
    				log "    Moving right"
    				niri msg action move-column-right
    			else
    				log "    Moving left"
    				niri msg action move-column-left
    			fi
    			sleep "$sleep_interval"
    		done
    	fi

    	if [ "$distance" -gt 0 ]; then
    		log "    Merging right"
    		niri msg action consume-or-expel-window-right
    	else
    		log "    Merging left"
    		niri msg action consume-or-expel-window-left
    	fi

    	# refocus tartget window
    	niri msg action focus-window --id "$target_id"
    	sleep "$sleep_interval"
    done

    if [ $iteration -eq "$max_iterations" ]; then
    	log "Error: Reached maximum iterations ($max_iterations)"
    	exit 1
    fi

    # Refocus target window
    niri msg action focus-window --id "$target_id"

    log "Success! All windows of class '$target_class' stacked in column $target_column"
  '';
}
