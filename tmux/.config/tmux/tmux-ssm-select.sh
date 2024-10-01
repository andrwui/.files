#!/bin/bash

tput civis

SESSIONS=$(tmux list-sessions -F "#{session_name}")
selected=0
session_list=($SESSIONS)

refresh_sessions() {
  SESSIONS=$(tmux list-sessions -F "#{session_name}")
  session_list=($SESSIONS)
  session_count=${#session_list[@]}
}

draw_menu() {
  clear
  echo
  for i in "${!session_list[@]}"; do
    if [ "$i" -eq "$selected" ]; then
      echo "> ${session_list[$i]}"
    else
      echo "  ${session_list[$i]}"
    fi
  done

  tput cup $((${#session_list[@]} + 1)) 0
}

clear_help_line() {
  tput cup $((${#session_list[@]} + 2)) 0
  echo
  echo -n "             "
  tput cup $((${#session_list[@]} + 2)) 0
}

read_input() {
  read -r -n1 -s key
  if [[ $key == $'\x1b' ]]; then
    return 1
  fi
  echo -n "$key"
  read -r REPLY
  echo "$REPLY"
  return 0
}

clear

while true; do
  draw_menu
  read -rsn1 input
  case "$input" in
    "s")
      ((selected--))
      [ "$selected" -lt 0 ] && selected=$((${#session_list[@]} - 1))
      ;;
    "d")
      ((selected++))
      [ "$selected" -ge ${#session_list[@]} ] && selected=0
      ;;
    "") tmux switch-client -t "${session_list[$selected]}"
        break
        ;;
    "q"|"Q")
        break
        ;;
    "R"|"r")
        clear_help_line
        echo -n "  rename: "
        if read_input; then
          tmux rename-session -t "${session_list[$selected]}" "$REPLY"
          refresh_sessions
        else
          clear_help_line
        fi
        ;;
    "D")
      clear_help_line
      echo -n "  delete '${session_list[$selected]}'?: "
      if read_input; then
        confirm=${REPLY:-n}
        if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
            if [ "${#session_list[@]}" -gt 1 ]; then
                next_session=$(( (selected + 1) % ${#session_list[@]} ))
                tmux switch-client -t "${session_list[$next_session]}"
            fi
            tmux kill-session -t "${session_list[$selected]}"
            refresh_sessions
            [ "$selected" -ge ${#session_list[@]} ] && selected=$((${#session_list[@]} - 1))
        else
            clear_help_line
        fi
      fi
      ;;
    "A"|"a")
        clear_help_line
        echo -n "  name: "
        if read_input; then
          tmux new-session -d -s "$REPLY" -c "$HOME"
          tmux switch-client -t "$REPLY"
          refresh_sessions
          selected=$((${#session_list[@]} - 1))
          break
        else
          clear_help_line
        fi
        ;;
  esac
done

tput cnorm

