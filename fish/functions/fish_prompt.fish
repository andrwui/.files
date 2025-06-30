function fish_prompt
  set -g __fish_git_prompt_show_informative_status 1
  set -g __fish_git_prompt_showupstream informative

  set -l cwd (basename (pwd))

  if test (pwd) = $HOME
    set cwd "~"
  end

  set -l git ''
  if command git rev-parse --is-inside-work-tree >/dev/null 2>&1
    set git (fish_vcs_prompt)
    set git (string trim $git)
    set git (string replace -r '^\(' '' -- $git)
    set git (string replace -r '\)$' '' -- $git)
    set git (string replace '|' ' | ' -- $git)
  end

  if test -n "$git"
    printf "%s [󰘬 %s]  " $cwd $git
  else
    printf "%s  " $cwd
  end
end

