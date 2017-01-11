#!/usr/bin/env bash
function spry_framework_autocomplete() {
  local cur prev
  COMPREPLY=()
  tasks=$(find "/tmp/dtux/tasks" -type f -iname "*.sh" -not -iname ".*.sh" |egrep -o "\w+.sh$" | sed 's/\.sh//g');
  cur="${COMP_WORDS[COMP_CWORD]}"
  COMPREPLY=( $(compgen -W "${tasks}" -- ${cur}) )

  return 0
}

complete -o nospace -F spry_framework_autocomplete dtux


