#!/usr/bin/env bash

function grunt_load_configurations() {

  if [ -z ${1:-} ]; then

    raise RequiredParameterNotFound "[grunt_load_configurations] Please provide a valid site"

  else

    _GRUNT_SUBSITE=${1}

  fi


  if [ -z ${2:-} ]; then

    raise RequiredParameterNotFound "[grunt_load_configurations] Please provide a valid subscription"

  else

    _GRUNT_SUBSCRIPTION=${2}

  fi

  shift 2
  _GRUNT_PARAMETERS=${@}

  out_warning "Loading configurations" 1

  local _GRUNT_YML_SUBSCRIPTION_FILE_CONFIGURATION="${SF_SCRIPTS_HOME}/config/subscriptions.yml"
  local _GRUNT_YML_SUBSCRIPTION_FILE_SUBSITE="${SF_SCRIPTS_HOME}/config/${_GRUNT_SUBSCRIPTION:-}.yml"

  if [ ! -f "${_GRUNT_YML_SUBSCRIPTION_FILE_CONFIGURATION}" ]; then

    raise FileNotFound "[grunt_load_configurations] File ${_GRUNT_YML_SUBSCRIPTION_FILE_CONFIGURATION} not found!"

  else

    eval $(yml_loader ${_GRUNT_YML_SUBSCRIPTION_FILE_CONFIGURATION} "_")

  fi

  if [ ! -f "${_GRUNT_YML_SUBSCRIPTION_FILE_SUBSITE}" ]; then

    raise FileNotFound "[grunt_load_configurations] Missing configuration file ${_GRUNT_YML_SUBSCRIPTION_FILE_SUBSITE}"

  else

    eval $(yml_loader ${_GRUNT_YML_SUBSCRIPTION_FILE_SUBSITE} "_")

  fi

  # Setup initials variables
  _GRUNT_SUBSITE_REPO=$(site_configuration_get_subsite_repo ${_GRUNT_SUBSITE} ${_GRUNT_SUBSCRIPTION})
  _GRUNT_SUBSITE_BRANCH=$(site_configuration_get_subsite_branch ${_GRUNT_SUBSITE} ${_GRUNT_SUBSCRIPTION})
  _GRUNT_SUBSITE_REAL_NAME=$(site_configuration_get_subsite_name ${_GRUNT_SUBSITE} ${_GRUNT_SUBSCRIPTION})

  # Get all site if necessary
  _GRUNT_GET_SITES=$(subscription_configuration_get_sites ${_GRUNT_SUBSCRIPTION})

  # Validate if subiste exists
  if [ -z ${_GRUNT_SUBSITE_REAL_NAME} ] || [ -z ${_GRUNT_SUBSITE_BRANCH} ] || [ -z ${_GRUNT_SUBSITE_REPO} ]; then

    out_danger "Site '${_GRUNT_SUBSITE}' not exists, select one from the list:" 1
    for SITE in ${_GRUNT_GET_SITES}; do

      echo -e "  ${BGREEN} ${SITE} ${COLOR_OFF}"

    done

    raise RequiredSiteNotFound "[grunt_load_configurations] Site '${_GRUNT_SUBSITE}' does not exist, please provid a valid site"

  fi

  _GRUNT_PLATFORM_PLATFORM_REPO=$(subscription_configuration_get_repository ${_GRUNT_SUBSCRIPTION})
  _GRUNT_PLATFORM_PLATFORM_REPO_NAME=$(git_extract_repository_name "${_GRUNT_PLATFORM_PLATFORM_REPO}")
  _GRUNT_PLATFORM_ACQUIA_BRANCH=$(subscription_configuration_get_plat_repo_resource ${_GRUNT_SUBSCRIPTION})
  _GRUNT_PLATFORM_ACQUIA_BRANCH_OUT=${_GRUNT_PLATFORM_ACQUIA_BRANCH/\//-}
  _GRUNT_PLATFORM_ACQUIA_BRANCH_OUT=${_GRUNT_PLATFORM_ACQUIA_BRANCH_OUT^^}


}

function grunt_execute_task() {


  if [ -z ${_GRUNT_PLATFORM_ACQUIA_BRANCH_OUT} ]; then

    raise RequiredParameterNotFound "[grunt_execute_task] Please provide a valid site"

  fi

  if [ -z ${_GRUNT_SUBSITE_REAL_NAME} ]; then

    raise RequiredParameterNotFound "[grunt_execute_task] Please provide a valid site"

  fi

  if [ -z ${_GRUNT_DOCKER_CONTAINER_CLI} ]; then

    raise RequiredParameterNotFound "[grunt_execute_task] Please provide a valid container"

  fi

  out_info "os_grunt_run_task ${_GRUNT_PLATFORM_ACQUIA_BRANCH_OUT} ${_GRUNT_SUBSITE_REAL_NAME} ${_GRUNT_DOCKER_CONTAINER_CLI} ${_GRUNT_PARAMETERS}"
  os_grunt_run_task ${_GRUNT_PLATFORM_ACQUIA_BRANCH_OUT} ${_GRUNT_SUBSITE_REAL_NAME} ${_GRUNT_DOCKER_CONTAINER_CLI} ${_GRUNT_PARAMETERS}

}
