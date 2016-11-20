#!/usr/bin/env bash

function out_info() {

  local _LINE_BREAK=""
  [ ${#} -ge 2 ] && [ ${2} -eq 1 ] && _LINE_BREAK="\n"

  printf "${_LINE_BREAK}${BBLUE}[$(date +%H:%M:%S)][ * ] $1 ${COLOR_OFF}\n"

}

function out_success() {

  local _LINE_BREAK=""
  [ ${#} -ge 2 ] && [ ${2} -eq 1 ] && _LINE_BREAK="\n"

  printf "${_LINE_BREAK}${BGREEN}[$(date +%H:%M:%S)][ ✔ ] $1 ${COLOR_OFF}\n"

}

function out_danger() {

  local _LINE_BREAK=""
  [ ${#} -ge 2 ] && [ ${2} -eq 1 ] && _LINE_BREAK="\n"

  printf "${_LINE_BREAK}${BRED}[$(date +%H:%M:%S)][ ✘ ] $1 ${COLOR_OFF}\n"


}

function out_warning() {

  local _LINE_BREAK=""
  [ ${#} -ge 2 ] && [ ${2} -eq 1 ] && _LINE_BREAK="\n"

  printf "${_LINE_BREAK}${BYELLOW}[$(date +%H:%M:%S)][ ! ] $1 ${COLOR_OFF}\n"

}

function out_question() {

  local _LINE_BREAK=""
  [ ${#} -ge 2 ] && [ ${2} -eq 1 ] && _LINE_BREAK="\n"

  printf "${_LINE_BREAK}${BYELLOW}[$(date +%H:%M:%S)][ ? ] $1 ${COLOR_OFF}\n"

}

function out_confirm() {
    _LINE_BREAK=""
    [ ${#} -ge 2 ] && [ ${2} -eq 1 ] && _LINE_BREAK="\n"

    out_question "${1:-Are you sure} [y/N]?" 1
    read  _RESPONSE
    case $_RESPONSE in
      [yY][eE][sS]|[yY]) return 0 ;;
      *) return 1 ;;
    esac

}

function out_separator() {

  echo -e "${_LINE_BREAK}\e[33;1m==============================================================================================\e[m"

}

function out_usage() {

  local _LINE_BREAK=""
  [ ${#} -ge 2 ] && [ ${2} -eq 1 ] && _LINE_BREAK="\n"

  echo -e "${_LINE_BREAK}${BYELLOW}[ USAGE ] $1 ${COLOR_OFF}"

}

function out_missing_configurations() {

  local _LINE_BREAK=""
  [ ${#} -ge 2 ] && [ ${2} -eq 1 ] && _LINE_BREAK="\n"

  echo -e "${_LINE_BREAK}${BYELLOW}[ Missing Configurations ] $1 ${COLOR_OFF}"

}

function out_check_status() {

  _LINE_BREAK=""
  [ ${#} -ge 4 ] && [ ${4} -eq 1 ] && _LINE_BREAK="\n"

  _STATUS_CODE=${1}
  #TODO use output api instead of just echo
  [ ${_STATUS_CODE} -eq 0 ] && out_success "$2" && return 0
  [ ${_STATUS_CODE} -ne 0 ] && out_danger "$3" && return 0

}

function out_notify() {

  # Types:
  # default: success
  # 1: sucess
  # 2: warning
  # 3: danger
  # 4: angry

  local _TITLE=${1:-}
  local _MESSAGE=${2:-}
  local _TYPE=${3:-}

  if (is_mac); then

    osascript -e 'display notification "'"$_MESSAGE"'" with title "'"$_TITLE"'"'

  elif [ -n "${_NOTIFY}" ]; then

    if [ "${_TYPE}" == "2" ] && [ -f "${SF_SCRIPTS_HOME}/vendor/core/images/warning.png" ]; then

      ${_NOTIFY} -i ${SF_SCRIPTS_HOME}/vendor/core/images/warning.png "${_TITLE}" "${_MESSAGE}"

    elif [ "${_TYPE}" == "3" ] && [ -f "${SF_SCRIPTS_HOME}/vendor/core/images/danger.png" ]; then

      ${_NOTIFY} -i ${SF_SCRIPTS_HOME}/vendor/core/images/danger.png "${_TITLE}" "${_MESSAGE}"

    elif [ "${_TYPE}" == "4" ] && [ -f "${SF_SCRIPTS_HOME}/vendor/core/images/angry.png" ]; then

      ${_NOTIFY} -i ${SF_SCRIPTS_HOME}/vendor/core/images/angry.png "${_TITLE}" "${_MESSAGE}"

    elif [ -f "${SF_SCRIPTS_HOME}/vendor/core/images/success.png" ]; then

      ${_NOTIFY} -i ${SF_SCRIPTS_HOME}/vendor/core/images/success.png "${_TITLE}" "${_MESSAGE}"

    fi

  else

    out_warning "Notify popup not detected. Please configure if you want a popup notification." 1

  fi

}

# display a message in red with a cross by it
# example
# echo out_fail "No"
function out_fail {

  # echo first argument in red
  echo -e "\e[31m✘ ${1:-}\033[0m"


}

# display a message in green with a tick by it
# example
# echo out_pass "Yes"
function out_pass {

  # echo first argument in green
  echo -e "\e[32m✔ ${1:-}\033[0m"

}

# echo pass or fail
# example
# echo out_if 0 "Passed"
# echo out_if 1 "Failed"
function out_if {

  if [ $1 == 0 ]; then
    out_pass ${2:-}
  else
    out_fail ${2:-}
  fi

}
