if [ (tty) = "/dev/tty1" ]
    exec Hyprland
end

if test (tty) = "/dev/tty1"
    exec Hyprland
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


# pnpm
set -gx PNPM_HOME "/home/andrw/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end
