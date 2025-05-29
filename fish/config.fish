if [ (tty) = "/dev/tty1" ]
    exec Hyprland
end

if test (tty) = "/dev/tty1"
    exec Hyprland
end

if not set -q SSH_AUTH_SOCK
    eval (ssh-agent -c)
    ssh-add ~/.ssh/id_ed25519
    ssh-add ~/.ssh/gitlab_ssh
end

if test -f ~/.config/fish/private.fish
  source ~/.config/fish/private.fish
end

for file in (find ~/.config/fish/sources -type f)
    if test -f $file
        if string match -qr '\.fish$' $file
            source $file
        end
    end
end

for file in (find ~/.config/fish/scripts -type f)
    if test -f $file
        if string match -qr '\.fish$' $file
            source $file
        end
    end
end

