#!/usr/bin/env bash

import solr

function drush_sqlc_database_import() {

  out_info "drush_sqlc_database_import" 1

}

function drush_vget() {

  local _VARIABLE=${1:-}
  shift 1
  local _PARAMS=${@}

  local _RESULT=$(drush_command ${_PARAMS})

  echo $(echo ${_RESULT} | sed "s/${_VARIABLE}: //g" | sed "s/\"//g")

}

function drush_command() {

  echo "$(${_DRUSH} ${@})"

}

function drush_command_on_subsite_from_acquia() {

  local _DRUSH_SUBSCRIPTION=${1:-}
  local _DRUSH_ENV=${2:-}
  local _DRUSH_SUB_SITE=${3:-}
  shift 3
  local _DRUSH_COMMAND=${@}
  local _DRUSH_COMMAND_CONVERTED=$(echo ${_DRUSH_COMMAND} | sed 's/\W//g')

  local _CACHE_FILE="${_SF_STATIC_CACHE_BASE_FOLDER}/${_TASK_NAME}/${FUNCNAME}/${_DRUSH_SUBSCRIPTION}_${_DRUSH_ENV}_${_DRUSH_SUB_SITE}_${_DRUSH_COMMAND_CONVERTED}.cache"

  if [ -s "${_CACHE_FILE}" ]; then

    ${_CAT} ${_CACHE_FILE}
    return 0

  else

    filesystem_create_file ${_CACHE_FILE}

  fi

  local _DRUSH_ALIAS="${_DRUSH_SUBSCRIPTION}.${_DRUSH_ENV}"
  local _SITES_PATH="/var/www/html/${_DRUSH_ALIAS}/docroot/sites"

  ${_DRUSH} @${_DRUSH_ALIAS} ssh "cd ${_SITES_PATH}/${_DRUSH_SUB_SITE}/ && drush ${_DRUSH_COMMAND}" | tee ${_CACHE_FILE}

}

function drush_add_language_domains() {

  local _LANGUAGE=${1:-}
  shift 1
  local _DOMAINS=$(echo ${@}|sed "s/ //g")

  local _CHECK_SITE_INSTALATION_MULTIDOMAIN=$(${_DRUSH} sqlq "SELECT * FROM languages;");
  if [ $? -eq 0 ]; then

    ${_DRUSH} sqlq "UPDATE languages SET domain='${_DOMAINS}' WHERE language='${_LANGUAGE}'"
    if [ $? -eq 0 ]; then

      out_success "Domains '${_DOMAINS}' updated for ${_LANGUAGE^^} language"

    else

      raise FailedToUpdateLanguagesTable "[drush_add_language_domains] Failed to update domains '${_DOMAINS}' for ${_LANGUAGE^^} language"

    fi

  fi

}

function drush_get_subsites_from_acquia() {

  local _DRUSH_SUBSCRIPTION=${1:-}
  local _DRUSH_ENV=${2:-}

  local _CACHE_FILE="${_SF_STATIC_CACHE_BASE_FOLDER}/${_TASK_NAME}/${FUNCNAME}/${_DRUSH_SUBSCRIPTION}_${_DRUSH_ENV}.cache"

  if [ -s "${_CACHE_FILE}" ]; then

    ${_CAT} ${_CACHE_FILE}
    return 0

  else

    filesystem_create_file ${_CACHE_FILE}

  fi

  local _DRUSH_ALIAS="${_DRUSH_SUBSCRIPTION}.${_DRUSH_ENV}"
  local _SITES_PATH="/var/www/html/${_DRUSH_ALIAS}/docroot/sites"

  ${_DRUSH} @${_DRUSH_ALIAS} ssh "ls -d ${_SITES_PATH}/*/" | sed "s#${_SITES_PATH}##g" | sed "s#/##g" | tee ${_CACHE_FILE}

}

function drush_ac_domain_list() {

  local _DRUSH_SUBSCRIPTION=${1:-}
  local _DRUSH_ENV=${2:-}

  local _CACHE_FILE="${_SF_STATIC_CACHE_BASE_FOLDER}/${_TASK_NAME}/${FUNCNAME}/${_DRUSH_SUBSCRIPTION}_${_DRUSH_ENV}.cache"

  if [ -s "${_CACHE_FILE}" ]; then

    ${_CAT} ${_CACHE_FILE}
    return 0

  else

    filesystem_create_file ${_CACHE_FILE}

  fi

  ${_DRUSH} @${_DRUSH_SUBSCRIPTION}.${_DRUSH_ENV} ac-domain-list | sed "s/ *name *: *//g" | tee ${_CACHE_FILE}

}

function drush_subsite_eval_from_acquia() {

  local _DRUSH_SUBSCRIPTION=${1:-}
  local _DRUSH_ENV=${2:-}
  local _DRUSH_SUB_SITE=${3:-}
  shift 3
  local _DRUSH_COMMAND=${@}

  local _CACHE_FILE="${_SF_STATIC_CACHE_BASE_FOLDER}/${_TASK_NAME}/${FUNCNAME}/${_DRUSH_SUBSCRIPTION}_${_DRUSH_ENV}_${_DRUSH_SUB_SITE}_${_DRUSH_COMMAND}.cache"

  if [ -s "${_CACHE_FILE}" ]; then

    ${_CAT} ${_CACHE_FILE}
    return 0

  else

    filesystem_create_file ${_CACHE_FILE}

  fi

  local _DRUSH_ALIAS="${_DRUSH_SUBSCRIPTION}.${_DRUSH_ENV}"
  local _SITES_PATH="/var/www/html/${_DRUSH_ALIAS}/docroot/sites"

  drush @${_DRUSH_ALIAS} ssh "cd ${_SITES_PATH}/${_DRUSH_SUB_SITE}/ && drush eval \"${_DRUSH_COMMAND}\"" | tee ${_CACHE_FILE}

}
