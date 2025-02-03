alias cd..="cd .."
alias ls="eza -l -a --no-permissions --no-user --no-filesize --color=never --icons --no-time"
alias cls="clear"
alias img="kitten icat"

function untar
  if test (count $argv) -gt 0
    if test -f $argv[1]
      set filename (basename $argv[1] .tar.gz)
      mkdir -p $filename
      tar -xvzf $argv[1] -C ./$filename/
    else
      echo "tar not found"
    end
  else
    echo "tar not provided" 
  end
end

