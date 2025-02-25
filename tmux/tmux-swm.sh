#!/bin/bash
POPUP_WIDTH="20%"
POPUP_HEIGHT="20%"

TMPFILE=$(mktemp /tmp/tmux-fzf.XXXXXX)

tmux popup -E -w "$POPUP_WIDTH" -h "$POPUP_HEIGHT" -d '#{pane_current_path}' "
  tmux list-windows -F '#{window_index}:#{window_name}#{?window_active, <,}' | 
  fzf --reverse --height=100% --border=none --prompt='window > ' \\
      --color=bw \\
      --expect=ctrl-r,ctrl-k \\
      --bind 'enter:execute-silent(echo enter {1} > $TMPFILE)+abort' \\
      --bind 'esc:abort' > $TMPFILE
"

if [ -s "$TMPFILE" ]; then
  KEY=$(head -1 "$TMPFILE")
  SELECTION=$(head -2 "$TMPFILE" | tail -1 | cut -d: -f1)
  
  if [ "$KEY" = "ctrl-r" ] && [ -n "$SELECTION" ]; then
    CURRENT_NAME=$(tmux display-message -p -t "$SELECTION" '#{window_name}')
    tmux command-prompt -p "New name:" -I "$CURRENT_NAME" "rename-window -t $SELECTION '%%'"
  elif [ "$KEY" = "ctrl-k" ] && [ -n "$SELECTION" ]; then
    tmux kill-window -t "$SELECTION"
  elif [[ "$KEY" == enter* ]] && [ -n "$SELECTION" ]; then
    tmux select-window -t "$SELECTION"
  fi
fi

rm -f "$TMPFILE"

exit 0
