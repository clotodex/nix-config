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
    max_iterations=10
    iteration=0
    previous_count=-1

    # Reconcile loop
    while [ $iteration -lt $max_iterations ]; do
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
    		echo "Error: No focused window found"
    		exit 1
    	fi

    	echo "Target: ID=$target_id, class=$target_class, column=$target_column"

    	# Get windows that need to be merged
    	windows_to_merge=$(get_windows_to_merge "$target_class" "$target_workspace" "$target_column")

    	# Count non-empty lines properly
    	if [ -z "$windows_to_merge" ]; then
    		merge_count=0
    	else
    		merge_count=$(echo "$windows_to_merge" | wc -l)
    	fi

    	if [ "$merge_count" -eq 0 ]; then
    		echo "All windows merged! (iteration $iteration)"
    		break
    	fi

    	# Check if we're making progress
    	if [ "$previous_count" -eq "$merge_count" ]; then
    		echo "Error: No progress made in iteration $iteration (still $merge_count windows to merge)"
    	fi
    	previous_count=$merge_count

    	echo "Iteration $iteration: $merge_count windows left to merge"

    	# Get next window to merge
    	next_window=$(echo "$windows_to_merge" | head -n 1)
    	next_id=$(echo "$next_window" | jq -r '.id')
    	next_column=$(echo "$next_window" | jq -r '.layout.pos_in_scrolling_layout[0]')

    	printf "  Target window: ID=%s, column=%s\n" "$target_id" "$target_column"
    	printf "  Next window to merge: ID=%s, column=%s\n" "$next_id" "$next_column"

    	if [ -z "$next_id" ] || [ "$next_id" = "null" ]; then
    		echo "Error: Could not get next window to merge"
    		exit 1
    	fi

    	echo "  Moving window ID=$next_id from column $next_column to column $target_column"
        distance=$(( target_column - next_column ))
    	abs_distance=''${distance#-}
    	echo "  Distance to target column: $distance"

    	# Focus the window to merge
    	niri msg action focus-window --id "$next_id"
    	sleep 0.05
    	if [ "$abs_distance" -gt 1 ]; then
    		echo "  Note: Window is more than one column away; will move it step by step"
    		for _ in $(seq 1 $((abs_distance - 1))); do
    			if [ "$distance" -gt 0 ]; then
    				echo "    Moving right"
    				niri msg action move-column-right
    			else
    				echo "    Moving left"
    				niri msg action move-column-left
    			fi
    			sleep 0.05
    		done
    	fi

    	if [ "$distance" -gt 0 ]; then
    		echo "    Merging right"
    		niri msg action consume-or-expel-window-right
    	else
    		echo "    Merging left"
    		niri msg action consume-or-expel-window-left
    	fi

    	# refocus tartget window
    	niri msg action focus-window --id "$target_id"
    	sleep 0.05
    done

    if [ $iteration -eq $max_iterations ]; then
    	echo "Error: Reached maximum iterations ($max_iterations)"
    	exit 1
    fi

    # Refocus target window
    niri msg action focus-window --id "$target_id"

    echo "Success! All windows of class '$target_class' stacked in column $target_column"
  '';
}
