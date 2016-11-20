#!/usr/bin/env bash

#----------------------------------------------------------
# Perform creating directory
#----------------------------------------------------------
function filesystem_create_folder() {

  local _FILESYSTEM_FOLDER=${1:-}

  if [ ! -d ${_FILESYSTEM_FOLDER} ]; then

    ${_MKDIR} -p ${_FILESYSTEM_FOLDER}

  fi

}

function filesystem_create_file() {

  local _FILESYSTEM_FILE=${1:-}
  local _FILESYSTEM_PARENT_FOLDER=$(dirname ${_FILESYSTEM_FILE})

  if [ ! -f ${_FILESYSTEM_FILE} ]; then

    if [ -n "${_FILESYSTEM_PARENT_FOLDER}" ] && [ ! -d ${_FILESYSTEM_PARENT_FOLDER} ]; then

      filesystem_create_folder ${_FILESYSTEM_PARENT_FOLDER}

    fi

    ${_TOUCH} ${_FILESYSTEM_FILE}

  fi

}

function filesystem_create_folder_777() {

  local _FILESYSTEM_FOLDER=${1:-}

  filesystem_create_folder ${_FILESYSTEM_FOLDER}

  local _FILESYSTEM_FOLDER_PERM=$(stat -c "%a" ${_FILESYSTEM_FOLDER})
  if [ ${_FILESYSTEM_FOLDER_PERM} -ne 777 ]; then

    ${_CHMOD} -R 777 "${_FILESYSTEM_FOLDER}"

  fi

}

function filesystem_create_file_777() {

  local _FILESYSTEM_FILE=${1:-}

  filesystem_create_file ${_FILESYSTEM_FILE}

  local _FILESYSTEM_FILE_PERM=$(stat -c "%a" ${_FILESYSTEM_FILE})
  if [ ${_FILESYSTEM_FILE_PERM} -ne 777 ]; then

    ${_CHMOD} 777 "${_FILESYSTEM_FILE}"

  fi

}

function filesystem_is_empty_folder() {

  local _FILESYSTEM_FOLDER=${1:-}
  local _FILESYSTEM_FILES_INSIDE=$(filesystem_list_files_in_folder ${_FILESYSTEM_FOLDER})

  if [ "${_FILESYSTEM_FILES_INSIDE}" ]; then

    return 1

  else

    return 0

  fi

}

function filesystem_list_files_in_folder() {

  local _FILESYSTEM_FOLDER=${1:-}
  local _FILESYSTEM_FILES_INSIDE=""

  if [ -d ${_FILESYSTEM_FOLDER} ]; then

    _FILESYSTEM_FILES_INSIDE=$(${_LS} -A ${_FILESYSTEM_FOLDER})

  fi

  echo ${_FILESYSTEM_FILES_INSIDE}

}

function filesystem_delete_file() {

  local _FILESYSTEM_FILE=${1:-}

  if [ -f ${_FILESYSTEM_FILE} ]; then

    ${_RMF} ${_FILESYSTEM_FILE}

  elif [ -d ${_FILESYSTEM_FILE} ]; then

    raise InvalidParameter "[filesystem_delete_file] Provided parameter is a folder and not a file"

  fi

}

function filesystem_delete_folder() {

  local _FILESYSTEM_FOLDER=${1:-}

  if [[ -d ${_FILESYSTEM_FOLDER} ]]; then

    ${_RMF} ${_FILESYSTEM_FOLDER}

  elif [ -f ${_FILESYSTEM_FOLDER} ]; then

    raise InvalidParameter "[filesystem_delete_folder] Provided parameter is a folder and not a folder"

  fi

}
