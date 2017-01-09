#!/usr/bin/env bash

function validate_boolean() {

  local _VALUE=${1:-}
  local _ARG_NAME=${2:-};
  local _FUNCTION=${3:-'validate_boolean'}
  local _MESSAGE="[${_FUNCTION}] Expected a valid boolean value (true|false|0|1) for ${_ARG_NAME}."

  echo ${_VALUE} | grep -Ew "(true|false|0|1)" > /dev/null 2>&1 && true
  if [ $? -ge 1 ] || [ -z ${_VALUE} ]; then

    raise ValidateError "${_MESSAGE}"

  fi

}

function validate_is_empty() {

  local _VALUE=${1:-}
  local _ARG_NAME=${2:-'string value'}
  local _FUNCTION=${3:-'validate_is_empty'}
  local _MESSAGE="[${_FUNCTION}] Expected a valid ${_ARG_NAME}."

  echo ${_VALUE} | grep -E "[[:print:]]" > /dev/null 2>&1 && true
  if [ $? -ge 1 ] || [ -z ${_VALUE} ]; then

    raise ValidateError "${_MESSAGE}"

  fi

}

function validate_options() {

  local _VALUE="${1:-}"
  local _LIST=$(echo ${2} | tr " " "\n"|awk '!x[$0]++' | tr "\n" " ")
  local _ARG_NAME=${3:-}
  local _FUNCTION=${4:-'validate_options'}
  local _MESSAGE="[${_FUNCTION}] ${_ARG_NAME} '${_VALUE}' does not exist, please provide a valid option."

  if  [[ -z "${1:-}" ]] || (! in_list? ${_VALUE} "${_LIST}"); then

    out_danger "Expected a valid options:" 1
    for OPTION in ${_LIST}; do

      echo -e "  ${BGREEN} ${OPTION} ${COLOR_OFF}"

    done

    raise ValidateError "${_MESSAGE}"

  fi

}

function validate_is_valid_path() {

  local _VALUE=${1:-}
  local _ARG_NAME=${2:-}
  local _FUNCTION=${3:-'validate_is_valid_path'}
  local _MESSAGE="[${_FUNCTION}] Expected a valid path."

  if [[ -z ${1:-} ]] || ([ ! -d ${_VALUE} ] && [ ! -f ${_VALUE} ]); then

    raise ValidateError "${_MESSAGE}"

  fi

}

function validate_is_valid_yaml() {

  local _VALUE=${1:-};
  local _SEPARATOR=${2:-"_"}
  local _FUNCTION=${3:-'validate_is_valid_yaml'}
  local _MESSAGE="[${_FUNCTION}] YAML file not found: [ ${_VALUE} ]."

  if [[ -z ${1:-} ]] || [ ! -f ${_VALUE} ]; then

    raise ValidateError "${_MESSAGE}"

  fi

  yml_parse ${_VALUE} ${_SEPARATOR}
  yay ${_VALUE} ${_SEPARATOR}

}


function validate_is_jira_tickets() {

  local _VALUE=${1:-}
  local _ARG_NAME=${2:-'string value'}
  local _FUNCTION=${3:-'validate_is_jira_ticket'}

  local _TICKETS=$(filter_string_parse '|' ${_VALUE})

  for TICKET in ${_TICKETS}; do

    echo "${TICKET}" | grep -Ew "(\w+-[0-9]+)" > /dev/null 2>&1 && true
    if [ $? -ge 1 ] || [ -z ${TICKET} ]; then

      local _MESSAGE="[${_FUNCTION}] Expected a valid ticket: ${TICKET}."
      raise ValidateError "${_MESSAGE}"

    fi

  done

}

# Any of the following can be used, only a few are demonstrated:
#[:alnum:]  # Alphanumeric characters
#[:alpha:]  # Alphabetic characters
#[:lower:]  # Lowercase letters
#[:upper:]  # Uppercase letters
#[:digit:]  # Decimal digits
#[:xdigit:] # Hexadecimal digits
#[:punct:]  # Punctuation
#[:blank:]  # Tabs and spaces
#[:space:]  # Whitespace characters
#[:cntrl:]  # Control characters
#[:print:]  # All printable characters
#[:graph:]  # All printable characters except for space
#[a-zA-Z0-9] # Same as [:alnum:]. POSIX can be used.
