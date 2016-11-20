#!/usr/bin/env bash

function parse_log() {

  local _PARSE_LOG_PATH=${1:-}
  local _PARSE_ANALYZE_SITE="${2:-}"
  local _PARSE_ANALYZE_SITE=$(echo ${_PARSE_ANALYZE_SITE}| sed 's|^http[s]://||g')

  local _LOGS=""

  if (detect_log_is_watchdog ${_PARSE_LOG_PATH}); then

    out_info "Checking watchdog logs" 1
    local _LOGS=$(${_GREP} "${_PARSE_ANALYZE_SITE}" ${_PARSE_LOG_PATH}|cut -d '|' -f3,9 |sed -e "s/request_id.*//g" |sort -d -f |uniq -c |sort -n |sed "s/|/ - /g")
    print_output_logs ${_PARSE_LOG_PATH} "${_LOGS}"

  elif (detect_log_is_errorlog ${_PARSE_LOG_PATH}); then

    out_info "Checking error logs" 1
    local _LOGS=$(${_GREP} "${_PARSE_ANALYZE_SITE}" ${_PARSE_LOG_PATH} |cut -d ' ' -f6-13 |sort -d -f |uniq -c |sort -rn |sed "s/,//g")
    print_output_logs ${_PARSE_LOG_PATH} "${_LOGS}"

  else

    out_danger "Logfile type not found:  ${_PARSE_LOG_PATH}" 1

  fi

}

function print_output_logs() {

  local _OUTPUT_LOG_PATH=${1}

  shift 1
  local _LOGS=${@}

  if [[ -z "${_LOGS}" ]]; then

    out_success "No errors found on: ${_OUTPUT_LOG_PATH}"

  else

    out_danger "Logs found:" 1
    for _LOG in "${_LOGS}"; do

      echo -e "${BWHITE}${_LOG} ${COLOR_OFF}"

    done

  fi

}


function detect_log_is_watchdog() {

  local _LOG_DETECT_WATCHDOG="${1}"

  test -z "$_LOG_DETECT_WATCHDOG" && return 1

  # Sanitize!
  local _LOG_DETECT_WATCHDOG=$(escape_arg "$_LOG_DETECT_WATCHDOG")
  echo "${_LOG_DETECT_WATCHDOG}" | ${_GREP} -wq "watchdog"
  return $?

}

function detect_log_is_errorlog() {

  local _LOG_DETECT_ERROR_LOG="${1}"

  test -z "$_LOG_DETECT_ERROR_LOG" && return 1

  # Sanitize!
  local _LOG_DETECT_ERROR_LOG=$(escape_arg "$_LOG_DETECT_ERROR_LOG")
  echo "${_LOG_DETECT_ERROR_LOG}" | ${_GREP} -wq "error"
  return $?

}
