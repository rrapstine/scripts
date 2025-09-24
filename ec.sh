#!/bin/bash
# =============================================================================
# Script Name : ec (Edit Config)
# Description : Fuzzy-find a config, open it in Neovim, and then
#             : prompt to commit any git changes upon closing.
# =============================================================================

CONFIG_DIR="$HOME/.config"

# Find all config directories
configs=($(find "$CONFIG_DIR" -mindepth 1 -maxdepth 1 -type d))

# Exit if no configs found
if [ ${#configs[@]} -eq 0 ]; then
  echo "No configs found."
  exit 1
fi

# Gather just the directory names
names=()
for p in "${configs[@]}"; do
  names+=("$(basename "$p")")
done

# Use fzf for fuzzy selection
selected=$(printf '%s\n' "${names[@]}" | fzf)

# Exit if nothing was selected
if [ -z "$selected" ]; then
  exit
fi

# Find the full path to the selected config
for p in "${configs[@]}"; do
  if [ "$(basename "$p")" = "$selected" ]; then
    config_path="$p"
    break
  fi
done

# Use a subshell to change directory and launch Neovim
(
  cd "$config_path" && nvim
)

# --- Git Prompt Logic ---
# After nvim closes, check if the directory is a git repository
if [ -d "$config_path/.git" ]; then
  # Check for uncommitted changes using the --porcelain flag for clean output.
  # The -C flag tells git to run as if it were in that directory.
  if [ -n "$(git -C "$config_path" status --porcelain)" ]; then
    # Print a newline for better formatting
    echo

    # Prompt the user for action
    read -p "You have uncommitted changes in $(basename "$config_path"). Commit now? (y/N) " -n 1 -r REPLY
    echo # Move to a new line after user input

    # If the user pressed 'y' or 'Y', take action
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      echo "Opening a shell in '$config_path' for you to commit."
      echo "Type 'exit' when you are finished."
      # Drop into a new interactive shell in the project's directory
      (
        cd "$config_path" && $SHELL
      )
    fi
  fi
fi
