function shell_framework_autocomplete() {
  local cur prev
  COMPREPLY=()
  tasks=$(find "${SF_SCRIPTS_HOME}/tasks" -type f -iname "*.sh" -not -iname ".*.sh" |egrep -o "\w+.sh$" | sed 's/\.sh//g');
  cur="${COMP_WORDS[COMP_CWORD]}"
  COMPREPLY=( $(compgen -W "${tasks}" -- ${cur}) )

  return 0
}
complete -o nospace -F shell_framework_autocomplete sf
