#!/usr/bin/env bash


function prelaunch_check_load_configurations() {

  if [ -z ${1:-} ]; then

    raise RequiredParameterNotFound "[prelaunch_check_load_configurations] Please provide a valid site"

  else

    _PRELAUNCH_CHECK_SUBSITE=${1}

  fi


  if [ -z ${2:-} ]; then

    raise RequiredParameterNotFound "[prelaunch_check_load_configurations] Please provide a valid subscription"

  else

    _PRELAUNCH_CHECK_SUBSCRIPTION=${2}

  fi

  if [ -z ${3:-} ]; then

    raise RequiredParameterNotFound "[prelaunch_check_load_configurations] Please provide a valid site URL"

  elif [[ ! "${3}" == *"http"* ]]; then

    raise InvalidParameter "[prelaunch_check_load_configurations] Please include also the protocol"

  else

    _PRELAUNCH_CHECK_SITE_URL=${3}

  fi

  out_warning "Loading script parameters" 1

  _PRELAUNCH_CHECK_REPO_PATH="${_PRELAUNCH_CHECK_WORKSPACE}/${_PRELAUNCH_CHECK_SUBSCRIPTION}"

  if [ ! -d "${_PRELAUNCH_CHECK_WORKSPACE}" ]; then

    ${_MKDIR} -p ${_PRELAUNCH_CHECK_WORKSPACE}

  fi

  slack_notify "Pre Launch Check for ${_PRELAUNCH_CHECK_SUBSITE} in ${_PRELAUNCH_CHECK_SUBSCRIPTION}"

}

function prelaunch_check_load_repository() {

  out_warning "Loading vendor repository information" 1
  prelaunch_check_load_vendor_repository

  out_warning "Gathering platform information" 1
  prelaunch_check_load_platform_repository

}

function prelaunch_check_database_configs() {

  out_warning "Checking expected database configurations" 1

  out_info "Checking for pending database updates. Expected \"No database updates required\"" 1
  local _PRELAUNCH_CHECK_DRUSH_ENVIRONMENT="${_PRELAUNCH_CHECK_SUBSCRIPTION}.${_PRELAUNCH_CHECK_DEFAULT_ENVIRONMENT}"
  drush_command @${_PRELAUNCH_CHECK_DRUSH_ENVIRONMENT} -l ${_PRELAUNCH_CHECK_SITE_URL} updb -n

  out_info "Checking the Janrain Entitlement. Should match <goc>_<region>_<country>_<brand>_<tld>" 1
  drush_command @${_PRELAUNCH_CHECK_DRUSH_ENVIRONMENT} -l ${_PRELAUNCH_CHECK_SITE_URL} vget janrain_entitlements_site_name

  out_info "Checking the Apache Solr SITE HASH" 1
  drush_command @${_PRELAUNCH_CHECK_DRUSH_ENVIRONMENT} -l ${_PRELAUNCH_CHECK_SITE_URL} vget apachesolr_site_hash

}

function prelaunch_check_grunt() {

  out_warning "Checking Grunt" 1

  local _PRELAUNCH_CHECK_DRUSH_ENVIRONMENT="${_PRELAUNCH_CHECK_SUBSCRIPTION}.${_PRELAUNCH_CHECK_DEFAULT_ENVIRONMENT}"
  out_info "Fetching active theme for ${_PRELAUNCH_CHECK_SUBSITE} in @${_PRELAUNCH_CHECK_DRUSH_ENVIRONMENT}" 1
  local _PRELAUNCH_CHECK_ACTIVE_THEME=$(drush_vget theme_default "@${_PRELAUNCH_CHECK_DRUSH_ENVIRONMENT} -l ${_PRELAUNCH_CHECK_SITE_URL} vget theme_default")
  out_info "Active theme found: ${_PRELAUNCH_CHECK_ACTIVE_THEME}"

  local _PRELAUNCH_CHECK_FULL_THEME_PATH="vendor_subs/${_PRELAUNCH_CHECK_SUBSCRIPTION}/docroot/sites/${_PRELAUNCH_CHECK_SUBSITE}/themes/${_PRELAUNCH_CHECK_ACTIVE_THEME}"
  local _OS_GRUNT_DOCKER_CONTAINER_CLI="os_cli"

  if (docker_container_exists ${_PRELAUNCH_CHECK_GRUNT_DOCKER_CONTAINER_CLI}); then

    os_grunt_run_task_full_path ${_PRELAUNCH_CHECK_FULL_THEME_PATH} "${_PRELAUNCH_CHECK_GRUNT_DOCKER_CONTAINER_CLI}"

  else

    out_danger "Container not started: ${_PRELAUNCH_CHECK_GRUNT_DOCKER_CONTAINER_CLI} "

  fi
}

function prelaunch_check_functionality() {

  out_warning "Checking if expected functionality is working" 1

  for _PAGE in ${_PRELAUNCH_CHECK_PAGES}; do

    prelaunch_check_page ${_PAGE}

  done

}

function prelaunch_check_large_images() {

  out_warning "Checking for files larger than 400KB" 1

  local _PRELAUNCH_CHECK_DRUSH_ENVIRONMENT="${_PRELAUNCH_CHECK_SUBSCRIPTION}.${_PRELAUNCH_CHECK_DEFAULT_ENVIRONMENT}"

  drush @${_PRELAUNCH_CHECK_DRUSH_ENVIRONMENT} ssh "find ${_PRELAUNCH_CHECK_DEFAULT_ENVIRONMENT}/sites/${_PRELAUNCH_CHECK_SUBSITE}/files -type f -size +400k -exec du -hs {} \;" | sort -rh

  out_danger "Analyze the files above and if necessary, create a Code Review sub-task in the Site Launch ticket listing the large images"

}

function prelaunch_check_diff_platform() {

  out_warning "Checking diff with base platform" 1
  prelaunch_check_analyze_diffs

}

function prelaunch_check_logs() {

  drush_rsync_logs ${_PRELAUNCH_CHECK_SUBSCRIPTION} ${_PRELAUNCH_CHECK_DEFAULT_ENVIRONMENT} ${_PRELAUNCH_CHECK_LOGS_PATH} ${_PRELAUNCH_CHECK_ERROR_LOGS}
  prelaunch_check_analyze_logs ${_PRELAUNCH_CHECK_SUBSCRIPTION} ${_PRELAUNCH_CHECK_DEFAULT_ENVIRONMENT} ${_PRELAUNCH_CHECK_SITE_URL} ${_PRELAUNCH_CHECK_LOGS_PATH} ${_PRELAUNCH_CHECK_ERROR_LOGS}

}
