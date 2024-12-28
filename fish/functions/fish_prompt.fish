function fish_prompt
  set_color white
  if [ "$HOME" = (pwd) ]
    printf "~"
  else
    printf (basename (pwd))
  end
  printf "  "
end
