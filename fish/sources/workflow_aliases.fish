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

  set selected_dir (find ~ -type d \( -name ".*" -o -path "*/eclipse-workspace/*" \) -prune -o -type d -print | fzf --color=bw)

  if test -n "$selected_dir"
    set session_name (basename $selected_dir | sed 's/^\./dot/')

    if not tmux has-session -t $session_name 2>/dev/null
      tmux new-session -d -s $session_name -c $selected_dir
    end

    if set -q TMUX
      tmux switch-client -t $session_name \; new-window -dn scratch -c $selected_dir \; send-keys 'nv' C-m 
    else
      tmux attach-session -t $session_name
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

