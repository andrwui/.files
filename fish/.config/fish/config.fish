set fish_greeting

if test -f ~/.config/fish/private.fish
    source ~/.config/fish/private.fish
end

set -gx EDITOR nvim

alias reboot="sudo reboot"
alias pacman="sudo pacman"
alias sysupdate="pacman -Syuu"


alias cd..="cd .."
alias ls="ls -a1"
alias cls="clear"

alias vpnmiem="sudo openfortivpn -c /etc/openfortivpn/config"

alias wlan0="iwctl station wlan0"

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

function tn --description 'Select directory with fzf and create tmux session'
    set selected_dir (find ~ -type d -print | fzf)
    
    if test -n "$selected_dir"
        set session_name (basename $selected_dir)
        
        if not tmux has-session -t $session_name 2>/dev/null
            tmux new-session -d -s $session_name -c $selected_dir
        end
        
        if set -q TMUX
            tmux switch-client -t $session_name \; new-window -dn scratch \; send-keys 'nv' C-m \; send-keys 'clear' C-m
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

function toshare
    cp $argv[1] ~/rdmiemshare/
end

alias bt="bluetuith"


zoxide init fish | source

set -gx PNPM_HOME "$HOME/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
    fish_add_path $PNPM_HOME
end


# pnpm
set -gx PNPM_HOME "/home/andrw/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end
