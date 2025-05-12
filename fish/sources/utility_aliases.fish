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

