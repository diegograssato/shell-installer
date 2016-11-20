#!/usr/bin/env bash

function boolean_validate() {

  if [ -z ${1:-} ]; then

    raise RequiredParameterNotFound "[boolean_validate] One argument expected"

  else

    local _VALUE=${1:-};

  fi
  local _TYPE=${2:-'boolean value'};

  echo ${_VALUE} | grep -Ew "(true|false|0|1)" > /dev/null 2>&1 && true
  if [ $? -ge 1 ]; then

    raise ValidateError "[boolean_validate] Expected a valid ${_TYPE}."

  fi

}

function is_empty_validate() {

  if [[ -z ${1:-} ]]; then

    raise RequiredParameterNotFound "[is_empty_validate] One argument expected"

  else

    local _VALUE=${1:-};

  fi
  local _TYPE=${2:-'string value'};

  echo ${_VALUE} | grep -E "[[:print:]]" > /dev/null 2>&1 && true
  if [ $? -ge 1 ]; then

    raise ValidateError "[is_empty_validate] Expected a valid ${_TYPE}."

  fi

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
