#!/bin/bash
WINDOW_COUNT=$(tmux list-windows | wc -l)
POPUP_WIDTH="20%"
POPUP_HEIGHT=$((WINDOW_COUNT + 4))
TMPFILE=$(mktemp /tmp/tmux-fzf.XXXXXX)
tmux popup -E -w "$POPUP_WIDTH" -h "$POPUP_HEIGHT" -d '#{pane_current_path}' "
  tmux list-windows -F '#{window_index}::#{window_name}#{?window_active, <,}' |
  awk -F'::' '{printf \"%s\\n\", \$2}' |
  fzf --reverse --prompt='window > ' \
      --no-info \
      --no-scrollbar \
      --color=bw,prompt: \
      --expect=ctrl-r,ctrl-k,ctrl-a \
      --bind 'enter:execute-silent(echo enter >> $TMPFILE)+execute-silent(echo {1} >> $TMPFILE)+abort' \
      --bind 'esc:abort' > $TMPFILE
"
if [ -s "$TMPFILE" ]; then
  KEY=$(head -1 "$TMPFILE")
  NAME=$(tail -1 "$TMPFILE" | sed 's/ <$//')
  INDEX=$(tmux list-windows -F '#{window_index}::#{window_name}' | awk -F'::' -v n="$NAME" '$2 == n {print $1; exit}')
  if [ "$KEY" = "ctrl-a" ]; then
    tmux command-prompt -p "window name:" "new-window -n '%%'"
  elif [ "$KEY" = "ctrl-r" ] && [ -n "$INDEX" ]; then
    tmux command-prompt -p "name:" -I "$NAME" "rename-window -t $INDEX '%%'"
  elif [ "$KEY" = "ctrl-k" ] && [ -n "$INDEX" ]; then
    tmux kill-window -t "$INDEX"
  elif [ "$KEY" = "enter" ] && [ -n "$INDEX" ]; then
    tmux select-window -t "$INDEX"
  fi
fi
rm -f "$TMPFILE"
exit 0
