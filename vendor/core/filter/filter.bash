#!/usr/bin/env bash

function filter_implode() {

  if [ -z ${1:-} ]; then

    local _SEPARATOR=","

  else

    local _SEPARATOR=${1:-}

  fi

  shift 1

  if [[ -z ${@} ]]; then

    raise RequiredParameterNotFound "[filter_implode] One argument expected"

  else

    local _LIST=${@}

  fi

  echo ${_LIST// /"${_SEPARATOR}"}

}

function filter_boolean() {

  local _BOOLEAN_PARAM=${1:-}

  if [ "${_BOOLEAN_PARAM}" == 1 ]; then

    _BOOLEAN_PARAM="true"

  elif [ "${_BOOLEAN_PARAM}" == 0 ]; then

    _BOOLEAN_PARAM="false"

  fi

  echo ${_BOOLEAN_PARAM}

}

function filter_string_parse() {

  local _DELIMITER="${1:-'|'}"
  shift 1
  local _STRINGS=${@}

  local _STRINGS_PARSED="$(echo ${_STRINGS}| tr "${_DELIMITER}" " ")"

  echo ${_STRINGS_PARSED}

}
