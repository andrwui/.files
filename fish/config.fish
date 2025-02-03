set fish_greeting

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




