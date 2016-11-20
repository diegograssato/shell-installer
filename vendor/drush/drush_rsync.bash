#!/usr/bin/env bash

function drush_rsync() {

  local _DRUSH_RSYNC_ORIGIN=${1:-}
  local _DRUSH_RSYNC_DESTINATION=${2:-}
  local _DRUSH_RSYNC_FORCE=${3:-}

  if [ -z "${_DRUSH_RSYNC_ORIGIN}" ]; then

    raise RequiredParameterNotFound "[drush_rsync] Please provide a valid origin"

  fi

  if [ -z "${_DRUSH_RSYNC_DESTINATION}" ]; then

    raise RequiredParameterNotFound "[drush_rsync] Please provide a valid destination"

  fi

  #TODO there should be a validation for _DRUSH_RSYNC_FORCE
  out_info "Rsynching files between ${_DRUSH_RSYNC_ORIGIN} and ${_DRUSH_RSYNC_DESTINATION}" 1
  ${_DRUSH} ${_DRUSH_RSYNC_FORCE} rsync ${_DRUSH_RSYNC_ORIGIN} ${_DRUSH_RSYNC_DESTINATION} --update --exclude="/js/js_*" --exclude="css/css_*" --exclude="node_modules" --exclude=".sass-cache" --mode="Cav" || true
}

#TODO why should this function exist?
function drush_rsync_clean() {

  local _DRUSH_RSYNC_ORIGIN=${1:-}
  local _DRUSH_RSYNC_DESTINATION=${2:-}
  local _DRUSH_RSYNC_FORCE=${3:-}
  local _DRUSH_RSYNC_FLAGS=${4:-}

  if [ -z "${_DRUSH_RSYNC_ORIGIN}" ]; then

    raise RequiredParameterNotFound "[drush_rsync_clean] Please provide a valid origin"

  fi

  if [ -z "${_DRUSH_RSYNC_DESTINATION}" ]; then

    raise RequiredParameterNotFound "[drush_rsync_clean] Please provide a valid destination"

  fi

  #TODO there should be a validation for _DRUSH_RSYNC_FORCE

  out_info "Clean rsynching files between ${_DRUSH_RSYNC_ORIGIN} and ${_DRUSH_RSYNC_DESTINATION}" 1
  ${_DRUSH} ${_DRUSH_RSYNC_FORCE} rsync ${_DRUSH_RSYNC_ORIGIN} ${_DRUSH_RSYNC_DESTINATION} ${_DRUSH_RSYNC_FLAGS}

}

function filesystem_check_large_files() {

  local _DRUSH_RSYNC_SUBSCRIPTION=${1:-}
  local _DRUSH_RSYNC_ENVIRONMENT=${2:-}
  local _DRUSH_RSYNC_SUB_SITE=${3:-}
  local _DRUSH_RSYNC_FILE_LIMIT="+10M"

  if [ -z "${_DRUSH_RSYNC_SUBSCRIPTION}" ]; then

    raise RequiredParameterNotFound "[filesystem_check_large_files] Please provide a subscription"

  fi

  if [ -z "${_DRUSH_RSYNC_ENVIRONMENT}" ]; then

    raise RequiredParameterNotFound "[filesystem_check_large_files] Please provide an environment"

  fi

  if [ -z "${_DRUSH_RSYNC_SUB_SITE}" ]; then

    raise RequiredParameterNotFound "[filesystem_check_large_files] Please provide a subsite"

  fi

  out_info "Searching for large files. Possibly zipped backups or psd files.\n"
  local _DRUSH_RSYNC_LARGE_FILES=$(${_DRUSH} @${_DRUSH_RSYNC_SUBSCRIPTION}.${_DRUSH_RSYNC_ENVIRONMENT} ssh "find ${_DRUSH_RSYNC_ENVIRONMENT}/sites/${_DRUSH_RSYNC_SUB_SITE}/files -type f -size ${_DRUSH_RSYNC_FILE_LIMIT}")

  if [ ! -z "${_DRUSH_RSYNC_LARGE_FILES}" ] ; then

    for _FILE in ${_DRUSH_RSYNC_LARGE_FILES}; do

      out_warning "\t${_FILE}"

    done

    out_confirm "Files above ${_DRUSH_RSYNC_FILE_LIMIT}B were found. Please evaluate if you should remove before downloading" 1

  fi

}

function drush_rsync_logs() {

  local _DRUSH_RSYNC_SUBSCRIPTION=${1:-}
  local _DRUSH_RSYNC_ENVIRONMENT=${2:-}
  local _DRUSH_RSYNC_LOGS_PATH=${3:-}
  shift 3
  local _DRUSH_RSYNC_LOG_FILES=${@}

  if [ -z "${_DRUSH_RSYNC_SUBSCRIPTION}" ]; then

    raise RequiredParameterNotFound "[drush_rsync_logs] Please provide a subscription"

  fi

  if [ -z "${_DRUSH_RSYNC_ENVIRONMENT}" ]; then

    raise RequiredParameterNotFound "[drush_rsync_logs] Please provide an environment"

  fi

  if [ -z "${_DRUSH_RSYNC_LOGS_PATH}" ]; then

    raise RequiredParameterNotFound "[drush_rsync_logs] Please provide a valid path"

  fi

  if [ -z "${_DRUSH_RSYNC_LOG_FILES}" ]; then

    raise RequiredParameterNotFound "[drush_rsync_logs] Please provide a subsite"

  fi

  local _DRUSH_RSYNC_FLAGS=""

  if [ -n "${_DRUSH_RSYNC_LOG_FILES}" ]; then

    for _LOG in ${_DRUSH_RSYNC_LOG_FILES}; do

      _DRUSH_RSYNC_FLAGS="${_DRUSH_RSYNC_FLAGS} --include=${_LOG}"

    done

  fi

  _DRUSH_RSYNC_FLAGS="${_DRUSH_RSYNC_FLAGS} --exclude=*"

  local _SUB_DOT_ENV="${_PRELAUNCH_CHECK_SUBSCRIPTION}.${_PRELAUNCH_CHECK_DEFAULT_ENVIRONMENT}"
  local _DRUSH_RSYNC_ENV_WEB_SERVERS=$(drush @${_SUB_DOT_ENV} ac-server-list | grep "name" | cut -d: -f2 | grep -E "web-|staging-|ded-")
  local _DRUSH_RSYNC_REMOTE_LOG_PATH="@${_SUB_DOT_ENV}:/var/log/sites/${_SUB_DOT_ENV}/logs"
  local _DRUSH_RSYNC_TEMP_PATH="${_DRUSH_RSYNC_LOGS_PATH}/${_SUB_DOT_ENV}"

  filesystem_create_folder_777 ${_DRUSH_RSYNC_TEMP_PATH}

  for _WEB_SERVER in ${_DRUSH_RSYNC_ENV_WEB_SERVERS}; do

    filesystem_create_folder_777 "${_DRUSH_RSYNC_TEMP_PATH}/${_WEB_SERVER}"
    drush_rsync_clean "${_DRUSH_RSYNC_REMOTE_LOG_PATH}/${_WEB_SERVER}/" "${_DRUSH_RSYNC_TEMP_PATH}/${_WEB_SERVER}/" "-y" "${_DRUSH_RSYNC_FLAGS}"

    for _LOG in ${_DRUSH_RSYNC_LOG_FILES}; do

      local _LOCAL_LOG_FILE="${_DRUSH_RSYNC_TEMP_PATH}/${_WEB_SERVER}/${_LOG}"

      if [ -f ${_LOCAL_LOG_FILE} ]; then

        ${_CAT} ${_LOCAL_LOG_FILE} >> ${_DRUSH_RSYNC_TEMP_PATH}/${_LOG}

      else

        out_danger "Logfile not found : ${_LOCAL_LOG_FILE}" 1

      fi

    done

  done

}
