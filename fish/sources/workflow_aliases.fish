function tmux
  if count $argv > /dev/null
    command tmux $argv
  else
    set -l sessions (command tmux list-sessions 2>/dev/null)
    if test $status -eq 0
      command tmux attach
    else
      command tmux
    end
  end
end


function tn 
  set selected_dir (find ~/ -type d \
    \( -path "*desarrollo-apia-miem*" -o \
       -path "*miemfs*" -o \
       -path "*node_modules*" -o \
       -path "*JaspersoftWorkspace*" -o \
       \( -path "*/.*" -not -path "*/.files*" \) \) -prune -o \
    -type d -print \
    2>/dev/null | fzf --reverse --prompt='dir > ' --no-info --color=bw,prompt: --bind=esc:abort | string trim)
  if test -n "$selected_dir"
    # Generate clean session name
    set session_name (basename "$selected_dir" | sed -E 's/^\./dot/' | tr '[:space:].' '_' | tr -cd '[:alnum:]_-' | sed 's/_*$//')
    # Check if session exists and create if it doesn't
    tmux has-session -t "$session_name" 2>/dev/null
    if test $status -ne 0
      tmux new-session -d -s "$session_name" -c "$selected_dir"
    end
    # Switch or attach to session
    if set -q TMUX
      tmux switch-client -t "$session_name" \; new-window -dn pnpm -c "$selected_dir" \; new-window -dn docker -c "$selected_dir" \; new-window -dn scratch -c "$selected_dir" \; send-keys 'nv' C-m 
    else
      tmux attach-session -t "$session_name"
    end
  end
end

function nv
  if test (count $argv) -gt 0
    if test -f $argv[1]
      nvim $argv[1]
    else
      set result (zoxide query $argv[1])
      if test -n "$result"
        nvim $result
      end
    end
  else
    nvim .
  end
end


alias pgcli='pgcli --less-chatty'
