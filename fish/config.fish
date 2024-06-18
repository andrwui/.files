if status is-interactive
    # Commands to run in interactive sessions can go here
end

set fish_greeting

alias ls="ls -a1"
alias reboot="sudo reboot"
alias nf="clear && echo && echo && echo && neofetch"
alias ss="hyprshot -z -m $1"
alias cc="code ~/.config"
alias cd..="cd .."
alias cls="clear"