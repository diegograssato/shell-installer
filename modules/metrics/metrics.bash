#!/usr/bin/env bash

_METRICS_SEPARATOR="|"

function metrics_init() {

  if [ "${_DEBUG}" == false ]; then # check if the debug flag is on

    metrics_header

  fi

}

function metrics_header() {

    _METRICS_CURRENT_EXECUTION=""
    _METRICS_LAST_TOUCH=${SECONDS}

    local _METRICS_USER="${USER:=\"anonymous\"}"
    local _METRICS_DATE=$(date +%Y-%m-%dT%H:%M:%S%z)
    local _METRICS_NO_SEPARATOR=1

    metrics_add ${_TASK_NAME} ${_METRICS_NO_SEPARATOR}
    metrics_add ${_METRICS_USER}
    metrics_add ${_METRICS_DATE}
    metrics_add ${_SF_SCRIPT_VERSION}

}

function metrics_touch() {

  if [ "${_DEBUG}" == false ]; then # check if the debug flag is on

    local _METRICS_TIME_DIFF=$((SECONDS-_METRICS_LAST_TOUCH))
    _METRICS_LAST_TOUCH=${SECONDS}

    metrics_add ${_METRICS_TIME_DIFF}

  fi
}

function metrics_add() {

  if [ "${_DEBUG}" == false ]; then # check if the debug flag is on

    local _METRICS_DATA=${1:-}
    local _METRICS_ARGUMENT=${2:-}

    # Add field separator if argument 1 is passed
    if [ "${_METRICS_ARGUMENT:-}" != "1" ]; then

      _METRICS_CURRENT_EXECUTION="${_METRICS_CURRENT_EXECUTION}${_METRICS_SEPARATOR}"

    fi

    # Always print the data
    _METRICS_CURRENT_EXECUTION="${_METRICS_CURRENT_EXECUTION}${_METRICS_DATA}"

  fi
}

function metrics_finalize() {

  if [ "${_DEBUG}" == false ]; then # check if the debug flag is on

    # Write to metrics file once a successfull execution was performed
    echo "${_METRICS_CURRENT_EXECUTION}" >> ${_METRICS_FILE}

  fi

}

function metrics_exit() {

  if [ "${_DEBUG}" == false ]; then # check if the debug flag is on

    # Add total execution time and save to log
    metrics_add ${SECONDS}
    metrics_get_metrics_file
    metrics_finalize

    # Sync any collected metrics data while the server was unreachable
    metrics_sync_data_to_server

  fi

}

function metrics_get_metrics_file() {

  local _FILENAME=${_TASK_NAME}
  if [ ! -z "${1:-}" ]; then

    local _FILENAME=${1}

  fi

  if (is_function? "os_nfs_server_fileserver_status" && os_nfs_server_fileserver_status && os_nfs_server_fileserver_configure_remote_server_in_fstab); then

    if [ -z "${_METRICS_NFS_FOLDER:-}" ]; then

      raise MissingRequiredConfig "[metrics_get_metrics_file] Please configure _METRICS_NFS_FOLDER in metrics_config.bash"

    fi

    _METRICS_FILE="${_METRICS_NFS_FOLDER}/${_FILENAME}.csv"

  else

    if [ -z "${_METRICS_FOLDER:-}" ]; then

      raise MissingRequiredConfig "[metrics_get_metrics_file] Please configure _METRICS_FOLDER in metrics_config.bash"

    fi

    _METRICS_FILE="${_METRICS_FOLDER}/${_FILENAME}.csv"

  fi

  filesystem_create_file ${_METRICS_FILE}

}

function metrics_sync_data_to_server() {

  if (! filesystem_is_empty_folder ${_METRICS_FOLDER}); then

    if (is_function? "os_nfs_server_fileserver_status" && os_nfs_server_fileserver_status && os_nfs_server_fileserver_configure_remote_server_in_fstab); then

      out_info "Synching offline data with server" 1

      local _METRICS_OFFLINE_DATA=$(filesystem_list_files_in_folder ${_METRICS_FOLDER})
      for _FILE in ${_METRICS_OFFLINE_DATA}; do

        out_info "Synching data from ${_METRICS_FOLDER}/${_FILE} to ${_METRICS_NFS_FOLDER}/${_FILE}"

        ${_CAT} "${_METRICS_FOLDER}/${_FILE}" >> "${_METRICS_NFS_FOLDER}/${_FILE}"
        filesystem_delete_file "${_METRICS_FOLDER}/${_FILE}"

      done

    fi

  fi

}

function metrics_abort() {

  metrics_header
  metrics_get_metrics_file "raise"
  metrics_add "$(echo ${@})"
  metrics_add ${SECONDS}
  metrics_finalize

}

# https://cloud.google.com/sdk/docs/#deb
# https://cloud.google.com/bigquery/bq-command-line-tool#runningquery
# bq query "SELECT count(script), script, AVG(step1), AVG(step2), AVG(step3) from lone_scripts.prelaunch_check GROUP BY script"

# Graphics:
# Total per script
# Total per OS per script
# Steps per script
