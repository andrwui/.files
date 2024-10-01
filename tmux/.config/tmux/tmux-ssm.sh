#!/bin/bash

# List all tmux sessions
SESSIONS=$(tmux list-sessions -F "#{session_name}")
session_list=($SESSIONS)
session_count=${#session_list[@]}

# Adjust popup height based on session count
popup_height=$((session_count + 4))

# Open the tmux popup
tmux popup -E -w 15% -h $popup_height -d '#{pane_current_path}' "bash -c '~/.config/tmux/tmux-ssm-select.sh'"


