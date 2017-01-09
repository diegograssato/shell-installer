#!/usr/bin/env bash

_TEMP_DEPENDENCY_LIST=("")
_MODULE_DEPENDENCIES=("")
_LOADED_MODULE_DEPENDENCIES=("")
_LOADED_MODULE_DEPENDENCIES_BATCH=("")

## Sets a globally scoped variable using Registry Pattern
## @param varname - the name of the variable
## @param varvalue - the value for the variable
function set () {
  local index="$1"
  shift
  _CORE_REGISTRY["$index"]="$*"
}

## Gets a globally scoped variable
## @param varname - the name of the variable
function get () {

  echo "${_CORE_REGISTRY[$1]}"

}

function setLog () {
  local index="$1"
  shift
  _LOG_PARMETERS["$index"]="$*"
}


## Returns whether a variable is set or not
## @param varname - the name of the variable
function is_set? () {
  key_exists? "$1" _CORE_REGISTRY
  return $?
}

## Unset a variable and all the ones that follow its name.
## For instance:
##   $ unset Bang.Test
## It would unset Bang.Test, Bang.Testing, Bang.Test.Something and so on
## @param varbeginning - the beginning of the varnames to be unsetted
function unset () {
  for key in "${!_CORE_REGISTRY[@]}"; do
    echo "$key" | ${_GREP} -q "^$1"
    [ $? -eq 0 ] && unset _CORE_REGISTRY["$key"]
  done
}

## Return whether the argument is a valid module
## @param module - the name of the module
function is_module? () {
  module.exists? "$1"
}

## Checks if the element is in the given array name
## @param element - element to be searched in array
## @param array - name of the array variable to search in
function in_array? () {
  local element="$1" array="$2"

  test -z "$element" -o -z "$array" && return 1
  # Sanitize!
  array=$(sanitize_arg "$array")
  local values="$(eval echo \"\${$array[@]}\")"
  element=$(escape_arg "$element")
  echo "$values" | ${_GREP} -wq "$element"
  return $?
}

## Checks if the element is in the given list _LIST=(element1 element2 element3)
## @param element - element to be searched in list
## @param array - name of the list variable to search in
function in_list? () {
  local element="$1"
  shift 1
  local list=${@}

  test -z "$element" -o -z "$list" && return 1
  element=$(escape_arg "$element")

  echo "$list" | ${_GREP} -owq "$element"
  return $?
}

## Get last element in list or array _LIST=(element1 element2 element3) return element3
## @param element - element to be searched in list
function get_last_element() {

  local element=($@)
  test -z "$element" -o -z "$@" && return 1
  local last_element=${element[${#element[@]}-1]}
  echo $last_element;

}


## Checks if the given key exists in the given array name
## @param key - key to check
## @param array - name of the array variable to be checked
function key_exists? () {
  local key="$1" array="$2"
  test -z "$key" -o -z "$array" && return 1
  array=$(sanitize_arg "$array")
  echo "$(eval echo \"\${!$array[@]}\")" | ${_GREP} -wq "$(escape_arg $key)"
  return $?
}

## Returns the escaped arg (turns -- into \--)
## @param arg - Argument to be escaped
function escape_arg () {
  local arg="$@"
  [ -z "$arg" ] && read arg
  if [ "${arg:0:1}" == '-' ]; then
    arg="\\$arg"
  fi
  echo -e "$arg"
}

## Returns the sinitized argument
## @param arg - Argument to be sinitized
function sanitize_arg () {
  local arg="$1"
  [ -z "$arg" ] && read arg
  arg=$(echo "$arg" | sed 's/[;&]//g' | sed 's/^ *//g ; s/ *$//g')
  echo "$arg"
}

## Checks if a function exists
## @param funcname -- Name of function to be checked
function is_function? () {
  declare -f "$1" &>/dev/null && return 0
  return 1
}

## Print to the stderr
## @param [text ...] - Text to be printed in stderr
function print_e () {
  echo -e "$*" >&2
}

## Raises an error an exit the code
## @param [msg ...] - Message of the error to be raised
function abort () {

  bootstrap_invoke_all "abort" "$*"

  out_danger "The program was aborted due to an error:\n\n\t$*" 1
  exit 2
}

## Raises an exception that can be cautch by catch statement
## @param exception - a string containing the name of the exception
function raise () {
  local exception="$1"
  shift

  abort "EXCEPTION $exception: $*"

}

function exception () {
  local exception="$1"
  local msg="$2"
  shift 2
    set "Core.Exception.Name" "$exception"
    set "Core.Exception.Msg" "$msg"
    set "Core.Exception.Parameters" "$@"
  #  echo ${!_LOG_PARMETERS[@]};

  json="["
  sep=""
  for file in ${!_LOG_PARMETERS[@]}; do
      file="{'"$file"':'"${_LOG_PARMETERS[$file]}"'}";
      file=${file//\\/\\\\}
      file=${file//\"/\\\"}
      printf -v json '%s%s%s' "$json" "$sep" "$file"
      sep=,
  done
  json+="]"
  echo $json
    raised_message
}

## Returns the last raised message by raise
function raised_message () {
  echo $(get "Core.Exception.Msg")
}

## Simple implementation of the try statement which exists in other languages
## @param funcname - a string containing the name of the function that can raises an exception
function try.do () {
  local funcname="$1"
  if is_function? "$funcname"; then
    shift
    $funcname "$@"
  fi
}

## Catches an exception fired by raise and executes a function
## @param exception - a string containing the exception fired by raise
## @param funcname - a string containing the name of the function to handle exception
function catch () {
  if [ "$(get Core.Exception.Name)" = "$1" ]; then
    is_function? "$2" && "$2"
  elif [ -z "$1" ]; then
    is_function? "$2" && "$2"
  fi
}

## Executes this command whether an exception is called or not
## @param funcname - a string containing the name of the function to be executed
function finally () {
  set "Core.Exception.Finally" "$1"
}

## End a try/catch statement
function try.end () {
  $(get "Core.Exception.Finally")
  unset Core.Exception
}

function resolve_path () {
  local file="$1"
  shift
  while [ -n "$1" ]; do
    local file_path="$1/$file.sh"

    test -f "$file_path" && echo -n "$file_path" && return 0
    shift
  done
  return 1
}

function import() {

  for _MODULE in ${@}; do

    if ! in_array? ${_MODULE} _MODULE_DEPENDENCIES && ! in_array? ${_MODULE} _LOADED_MODULE_DEPENDENCIES; then

      _MODULE_DEPENDENCIES=(${_MODULE_DEPENDENCIES[@]} $_MODULE)

    fi
  done

}

# Check 1 if global command line program installed, else 0
# example:
# echo "node: $(program_is_installed node)"
function program_is_installed() {

  # set to 1 initially
  local _return=1
  # set to 0 if not found
  if (is_linux); then

    dpkg -l | cut -d ' ' -f1,3 | grep -Eo "^ii ${1}$" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
      local _return=0
    fi


  elif (is_mac); then

    brew list -1 | grep -qw "${1}"
    if [ $? -eq 0 ]; then
      local _return=0
    fi

  fi

  # return value
  echo "$_return"

}

# Install a new software
# example
# install_software sshpass"
function install_software() {

  # set to 0 if not found
  local _softwares_not_installed=""
  for s in "${@}"; do

    if [ $(program_is_installed ${s}) == 1 ]; then

      _softwares_not_installed="${s} ${_softwares_not_installed}"

    fi

  done

  if (is_linux); then

    sudo apt-get -y --no-install-recommends install ${_softwares_not_installed}
    return $?

  elif (is_mac); then

    brew install ${_softwares_not_installed}
    return $?

  fi

}

# Remove a software
# example
# remove_software sshpass"
function remove_software() {

  # set to 0 if not found
  local _softwares_are_removed=""
  for r in ${@}; do

    if [ $(program_is_installed ${r}) == 0 ]; then

      _softwares_are_removed="${r} ${_softwares_are_removed}"

    fi

  done

  if (is_linux); then

    sudo apt-get -y remove ${_softwares_are_removed} --purge
    return $?

  elif (is_mac); then

    brew remove ${_softwares_are_removed}
    return $?

  fi

}

# Update system repository
# example:
# update_system_repo"
function update_system_repo() {

  # set to 0 if not found
  if (is_linux); then

    sudo apt-get update
    return $?

  elif (is_mac); then

    brew update
    return $?

  fi

}

function lowercase() {
  echo "$1" | sed "y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/"
}


function get_os() {

  local OS=$(uname)
  if [ "${OS}" == "${1}" ]; then

    return 0

  else

    return 1

  fi

}

function is_linux() {

  if (get_os "Linux"); then

    return 0

  else

    return 1

  fi

}

function is_mac() {

  if (get_os "Darwin"); then

    return 0

  else

    return 1

  fi
}
