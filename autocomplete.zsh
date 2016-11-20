_sf_get_autocomplete_list () {

  find "${SF_SCRIPTS_HOME}/tasks" -type f -iname "*.sh" -not -iname ".*.sh" |egrep -o "\w+.sh$" | sed 's/\.sh//g'

}

_sf_complete () {

  compadd $(_sf_get_autocomplete_list)
  
}

compdef _sf_complete ${SF_SCRIPTS_HOME}/main.sh
