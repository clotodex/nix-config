#!/usr/bin/env bash

source .env
export NIX_CONFIG

#echo "This will need root rights"
#sudo echo "Sudo activated"
#
## make sure git is commited
#
## should not need this
## nix-channel --update || exit
#
## interactive flake lock update
#
#nh os switch --nom --ask --update || exit
#-s <name-of-entry>
#git add flake.lock
#git commit -m "chore: update system"

explanation="
Explanation of the Flow in the Script:
• Pre-flight checks:
  1) We check that the git repo is clean. If not, we warn the user and ask if they want to continue anyway.  
  2) We collect all flake inputs (excluding “root”) by parsing flake.lock with jq.  
  3) For each input, we try “nix flake update --update-input <input>” and see if that changes the lock file. We store that information in NEEDS_UPDATE, then revert each time, so we don’t modify the lock file permanently yet.  
  4) We present the user with the list of inputs that have updates and allow them to choose between “update all” or individually picking inputs (attempting to use fzf if available).

• Updating:
  1) We run nix flake update --update-input for each selected input, resulting in a final changed lock file with only the chosen updates.  
  2) We ensure sudo privileges so that the subsequent system build can proceed.  
  3) We attempt a build (either via nh or nixos-rebuild). If it succeeds, we commit flake.lock. If it fails, we revert flake.lock.

Possible Expansions or Alternatives:
1. Manage multiple branches: Instead of committing to your main branch, you could create a dedicated “upgrade” branch, commit the new lock there, and merge back once tested.  
2. Stash or commit working changes first: You could enforce a stash or require a clean repo so that partial changes do not interfere.  
3. More robust build steps: Instead of just “switch,” you might want to do additional QA steps (e.g., “nix flake check” or custom tests).  
4. Automatic reverts or partial reverts: If the build fails on certain inputs, you could revert only those inputs and re-try, etc.  
5. Provide more advanced UI: Instead of simple shell-based Q&A, you could make use of whiptail/dialog, or a TUI library in Python.  
6. Use the nh “-u” or “--update” flag to automatically update your flake. This script demonstrates doing it manually, but you could rely more heavily on nh’s built-in capabilities (nh os switch -u).

Open Questions You Might Clarify:
• Do you prefer one big commit or separate commits for each updated input?  
• Should we always bail out at the first build failure, or try partial reverts automatically?  
• Do you want further integration with Nix CLI flags (like –verbose, –diff-provider, –dry-run)?  
• Would you like an optional “nix store diff-closures” step to see the difference in package closure sizes before switching?

Feel free to adapt this script further to your exact requirements—particularly around how you pick and commit your updated inputs, and how you build and activate the new system configuration.
"

#!/usr/bin/env bash
# Interactive NixOS upgrade script example

set -euo pipefail

###############################################################################
# EDITABLE VARIABLES
###############################################################################
# Path to your flake-based Nix configuration repository
FLAKE_REPO="${FLAKE_REPO:-$HOME/nix-config}"
# Default hostname or system config name you want to build
# (if you use e.g. "nh os switch -H myhostname" or "nixos-rebuild switch --flake .#myhostname")
HOSTNAME_DEFAULT="${HOSTNAME_DEFAULT:-$(hostname)}"

###############################################################################
# HELPER FUNCTIONS
###############################################################################

die() {
  echo "ERROR: $*" >&2
  exit 1
}

msg() {
  echo -e "\033[1;32m$*\033[0m"
}

warn() {
  echo -e "\033[1;33m$*\033[0m"
}

confirm_or_exit() {
  read -r -p "${1:-"Do you want to continue?"} [y/N] " resp
  case "$resp" in
    [yY][eE][sS]|[yY]) 
      echo "Continuing..."
      ;;
    *)
      echo "Exiting."
      exit 1
      ;;
  esac
}

# Check if a command is available
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Simple check for fzf
# If not found, fallback to a basic "select"
choose_from_list() {
  local list=("$@")
  
  # Handle empty input
  if [ ${#list[@]} -eq 0 ]; then
    return 0
  fi
  
  if command_exists fzf; then
    printf '%s\n' "${list[@]}" | fzf --multi
  else
    # fallback to a simple select
    PS3="Pick an input to update (or multiple, separated by spaces). Enter '0' or 'done' to finish: "
    local chosen=()
    # Save and restore IFS
    local OLD_IFS="$IFS"
    IFS=$'\n'
    select item in "${list[@]}" "done"; do
      if [[ "$item" == "done" || "$REPLY" == "0" ]]; then
        break
      elif [ -n "$item" ]; then
        chosen+=("$item")
      fi
    done
    # Print the results to stdout (similar to fzf behavior)
    printf '%s\n' "${chosen[@]}"
    IFS="$OLD_IFS"
  fi
}

###############################################################################
# PRE-FLIGHT
###############################################################################

cd "$FLAKE_REPO" || die "Could not cd into $FLAKE_REPO"

msg ">>> Checking for a clean git repository..."
if [ -n "$(git status --porcelain)" ]; then
  warn "Your repository is not clean. It is recommended to commit or stash changes before updating."
  confirm_or_exit "Do you still want to continue without committing/stashing your changes?"
fi

msg ">>> Gathering all flake inputs..."
if [ ! -f "flake.lock" ]; then
  die "No flake.lock found in $FLAKE_REPO"
fi

# In the lock file, every node except "root" usually represents a flake input
#ALL_INPUTS=($(jq -r '.nodes | to_entries | map(select(.key != "root")) | .[].key' flake.lock))
ALL_INPUTS=($(nix flake metadata --json | jq -r '.locks.nodes.root.inputs | to_entries | .[].key'))
if [ ${#ALL_INPUTS[@]} -eq 0 ]; then
  msg "No flake inputs found. Nothing to update."
  exit 0
fi

msg ">>> Checking which inputs have new versions available..."
# We will record which inputs have changes available
NEEDS_UPDATE=()

# We do a small trick: 
#  1) We temporarily update each input 
#  2) Check if flake.lock changed 
#  3) Revert if changed, but remember that changes are available

for input in "${ALL_INPUTS[@]}"; do
  echo "Checking $input..."
  # Stash a copy of flake.lock
  cp flake.lock flake.lock.bak
  # Try updating this specific input
  nix flake update "$input" >/dev/null 2>&1 || true

  # Check diff
  if ! diff -q flake.lock flake.lock.bak >/dev/null; then
    # Means there's a newer version for this input
    NEEDS_UPDATE+=("$input")
  fi

  # Revert changes
  mv flake.lock.bak flake.lock
done

if [ ${#NEEDS_UPDATE[@]} -eq 0 ]; then
  msg "All inputs are already up to date. Nothing to update. Exiting."
  exit 0
fi

msg ">>> The following inputs have newer versions available:"
printf '%s\n' "${NEEDS_UPDATE[@]}"

msg "You can choose to update all or only specific inputs."
update_selection=""
read -r -p "Update ALL (a) / choose individual (c) / abort (q)? [a/c/q]: " choice
case "$choice" in
  [aA])
    update_selection=("${NEEDS_UPDATE[@]}")
    ;;
  [cC])
    # Let user pick from NEEDS_UPDATE
    chosen=$(choose_from_list "${NEEDS_UPDATE[@]}")
	echo "chosen: $chosen"
	# Convert the multi-line output into an array
	mapfile -t update_selection <<<"$chosen"
    ;;
  *)
    msg "Aborting."
    exit 0
    ;;
esac

if [ ${#update_selection[@]} -eq 0 ]; then
  msg "No inputs selected. Exiting."
  exit 0
fi

msg ">>> Updating selected inputs in flake.lock..."
for input in "${update_selection[@]}"; do
  msg "Updating $input..."
  nix flake update --update-input "$input"
done

###############################################################################
# UPGRADE
###############################################################################

# 1) Ensure we have root privileges (may prompt for sudo password)
msg ">>> Trying to get root privileges..."
if ! sudo -n true 2>/dev/null; then
  warn "Sudo access required. Please enter your password if prompted."
  sudo true
fi

# 2) Attempt to build the system
msg ">>> Building and switching to the new system configuration..."

# -- Option A: Using nh (if you want). Example:
#    nh os switch --update --hostname "$HOSTNAME_DEFAULT" "$FLAKE_REPO"
#
# -- Option B: Using nixos-rebuild directly:
#    sudo nixos-rebuild switch --flake ".#${HOSTNAME_DEFAULT}"

# First commit the flake.lock changes
COMMIT_MSG="flake.lock update ($(date +%Y-%m-%d))"
msg ">>> Committing the updated flake.lock with the message: '$COMMIT_MSG'"
git add flake.lock
git commit -m "$COMMIT_MSG"

# Get the commit hash and set it as NIXOS_LABEL
COMMIT_HASH=$(git rev-parse HEAD)
export NIXOS_LABEL="$COMMIT_HASH"

msg ">>> Building system with NIXOS_LABEL=$NIXOS_LABEL"
if nh os switch --ask; then
  msg ">>> Build and switch successful!"
  exit 0
else
  warn ">>> Build failed. Reverting commit..."
  git reset --soft HEAD~1
  # TODO: git restore flake.lock
  msg "Exiting with error."
  exit 1
fi

