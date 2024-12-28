while inotifywait -r -e close_write "/home/andrw/.config/ags/" ; do 
  killall ags 
  ags & disown
done
