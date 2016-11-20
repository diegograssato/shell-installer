#!/usr/bin/env bash

function drush_load_configurations() {

  if [ -z ${1:-} ]; then

    raise RequiredParameterNotFound "[drush_load_configurations] Please provide a valid site"

  else

    _DRUSH_SUBSITE=${1}

  fi


  if [ -z ${2:-} ]; then

    raise RequiredParameterNotFound "[drush_load_configurations] Please provide a valid subscription"

  else

    _DRUSH_SUBSCRIPTION=${2}

  fi

  shift 2
  if [[ -z ${@:-} ]]; then

    raise RequiredParameterNotFound "[drush_load_configurations] Please provide a valid drush command"

  else

    _DRUSH_COMMANDS=${@}

  fi

  out_warning "Loading configurations" 1

  local _DRUSH_YML_SUBSCRIPTION_FILE_CONFIGURATION="${SF_SCRIPTS_HOME}/config/subscriptions.yml"
  local _DRUSH_YML_SUBSCRIPTION_FILE_SUBSITE="${SF_SCRIPTS_HOME}/config/${_DRUSH_SUBSCRIPTION:-}.yml"

  if [ ! -f "${_DRUSH_YML_SUBSCRIPTION_FILE_CONFIGURATION}" ]; then

    raise FileNotFound "[drush_load_configurations] File ${_DRUSH_YML_SUBSCRIPTION_FILE_CONFIGURATION} not found!"

  else

    eval $(yml_loader ${_DRUSH_YML_SUBSCRIPTION_FILE_CONFIGURATION} "_")

  fi

  if [ ! -f "${_DRUSH_YML_SUBSCRIPTION_FILE_SUBSITE}" ]; then

    raise FileNotFound "[drush_load_configurations] Missing configuration file ${_DRUSH_YML_SUBSCRIPTION_FILE_SUBSITE}"

  else

    eval $(yml_loader ${_DRUSH_YML_SUBSCRIPTION_FILE_SUBSITE} "_")

  fi

  subscription_configuration_check_subsite ${_DRUSH_SUBSCRIPTION} ${_DRUSH_SUBSITE}

  # Setup initials variables
  _DRUSH_SUBSITE_REAL_NAME=$(site_configuration_get_subsite_name ${_DRUSH_SUBSITE} ${_DRUSH_SUBSCRIPTION})

  _DRUSH_PLATFORM_REPO_RESOURCE=$(subscription_configuration_get_platform_path "${_DRUSH_SUBSCRIPTION}")

}

function drush_execute_task() {

  out_warning "Running drush command in local site" 1

  local _DRUSH_SITE_PATH="${_DRUSH_APACHE_PATH}/${_DRUSH_PLATFORM_REPO_RESOURCE^^}/docroot/sites/${_DRUSH_SUBSITE_REAL_NAME}"
  os_command_run_task ${_DRUSH_DOCKER_CONTAINER_CLI} ${_DRUSH_SITE_PATH} "drush ${_DRUSH_COMMANDS}"
  out_check_status $? "Drush command runned successfully" "Drush command failed"

}
