#!/bin/bash
POPUP_WIDTH="20%"
POPUP_HEIGHT="30%"
TMPFILE=$(mktemp /tmp/tmux-sessions-fzf.XXXXXX)
SESSIONS=$(tmux list-sessions -F '#{session_name}')
if [ -z "$SESSIONS" ]; then
  echo "No tmux sessions found."
  exit 0
fi
tmux popup -E -w "$POPUP_WIDTH" -h "$POPUP_HEIGHT" -d '#{pane_current_path}' "
  tmux list-sessions -F '#{session_name}#{?session_attached, <,}' | 
  fzf --reverse --height=100% --border=none --prompt='session > ' \\
      --color=bw \\
      --expect=ctrl-r,ctrl-k \\
      --bind 'esc:abort' > $TMPFILE
"
if [ -s "$TMPFILE" ]; then
  KEY=$(head -1 "$TMPFILE")
  SELECTION=$(head -2 "$TMPFILE" | tail -1 | sed 's/ <$//')
  if [ "$KEY" = "ctrl-r" ] && [ -n "$SELECTION" ]; then
    tmux command-prompt -p "New name:" -I "$SELECTION" "rename-session -t \"$SELECTION\" '%%'"
  elif [ "$KEY" = "ctrl-k" ] && [ -n "$SELECTION" ]; then
    tmux kill-session -t "$SELECTION"
  else
    tmux switch-client -t "$SELECTION"
  fi
fi
rm -f "$TMPFILE"
exit 0
