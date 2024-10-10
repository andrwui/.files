if status is-interactive
    # Commands to run in interactive sessions can go here
end

if test -f ~/.config/fish/private.fish
    source ~/.config/fish/private.fish
end

set fish_greeting

alias reboot="sudo reboot"
alias pacman="sudo pacman"
alias sysupdate="pacman -Syuu"


alias cd..="cd .."
alias ls="ls -a1"
alias cls="clear"
alias rm="trash"

alias vpnmiem="sudo openfortivpn -c /etc/openfortivpn/config"

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

alias wlan0="iwctl station wlan0"

function tn --description 'Select directory with fzf and create tmux session'
    set selected_dir (find ~ -type d -print | fzf)
    
    if test -n "$selected_dir"
        set session_name (basename $selected_dir)
        
        if not tmux has-session -t $session_name 2>/dev/null
            tmux new-session -d -s $session_name -c $selected_dir
        end
        
        if set -q TMUX
            tmux switch-client -t $session_name
        else
            tmux attach-session -t $session_name
        end
    end
end


function nv 
    if test (count $argv) -gt 0
        set dir (zoxide query $argv[1] )
        if test -n "$dir"
            nvim $dir
        end
       else
        nvim .
    end
end


function toshare
    cp $argv[1] ~/rdmiemshare/
end

alias bt="bluetuith"

fish_add_path /home/andrw/.spicetify

thefuck --alias | source
zoxide init fish | source
