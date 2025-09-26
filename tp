#!/bin/bash#
# =============================================================================
# Script Name : tp (Tmux Project Launcher)
# Description : Fuzzy-find a project and attach to or create a tmux session
# Author      : rrapstine
# License     : MIT
# Version     : 1.0.0
# =============================================================================

CODE_DIR="$HOME/Code"

# Find all project directories two levels deep
projects=($(find "$CODE_DIR" -mindepth 2 -maxdepth 2 -type d))

# Exit if no projects found
if [ ${#projects[@]} -eq 0 ]; then
  echo "No projects found."
  exit 1
fi

# Gather just the directory names
names=()
for p in "${projects[@]}"; do
  names+=("$(basename "$p")")
done

# Use fzf for fuzzy selection
selected=$(printf '%s\n' "${names[@]}" | fzf)

# Exit if nothing was selected
if [ -z "$selected" ]; then
  exit
fi

# Find the full path to the selected project
for p in "${projects[@]}"; do
  if [ "$(basename "$p")" = "$selected" ]; then
    project_path="$p"
    break
  fi
done

# Attach to an existing tmux session, or create a new one
if tmux has-session -t "$selected" 2>/dev/null; then
  tmux attach -t "$selected"
else
  tmux new-session -s "$selected" -c "$project_path"
fi
