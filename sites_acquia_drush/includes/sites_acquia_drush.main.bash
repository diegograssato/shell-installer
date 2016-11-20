#!/usr/bin/env bash

function sites_acquia_drush_load_configurations() {

  if [ -z ${1:-} ]; then

    raise RequiredParameterNotFound "[sites_acquia_drush_load_configurations] Please provide a valid subscription"

  else

    _SITES_ACQUIA_DRUSH_SUBSCRIPTION=${1}

  fi

  if [ -z ${2:-} ]; then

    raise RequiredParameterNotFound "[sites_acquia_drush_load_configurations] Please provide a valid environment"

  else

    _SITES_ACQUIA_DRUSH_ENVIRONMENT=${2}

  fi

  shift 2

  if [[ -z ${@:-} ]]; then

    raise RequiredParameterNotFound "[sites_acquia_drush_load_configurations] Please provide a valid drush command"

  else

    _SITES_ACQUIA_DRUSH_COMMANDS=${@}

  fi

  _SITES_ACQUIA_DRUSH_SITES=""

  out_warning "Loading configurations" 1


  _SITES_ACQUIA_DRUSH_ACQUIA_FILE="${_SF_STATIC_CACHE_BASE_FOLDER}/${_TASK_NAME}/${FUNCNAME}/${_SITES_ACQUIA_DRUSH_SUBSCRIPTION}_${_SITES_ACQUIA_DRUSH_ENVIRONMENT}_acquia.cache"
  _SITES_ACQUIA_DRUSH_YML_FILE="${_SF_STATIC_CACHE_BASE_FOLDER}/${_TASK_NAME}/${FUNCNAME}/${_SITES_ACQUIA_DRUSH_SUBSCRIPTION}_${_SITES_ACQUIA_DRUSH_ENVIRONMENT}_yml.cache"

  filesystem_create_file ${_SITES_ACQUIA_DRUSH_ACQUIA_FILE}
  filesystem_create_file ${_SITES_ACQUIA_DRUSH_YML_FILE}

  local _SITES_ACQUIA_DRUSH_YML_SUBSCRIPTION_FILE_CONFIGURATION="${SF_SCRIPTS_HOME}/config/subscriptions.yml"

  if [ ! -f "${_SITES_ACQUIA_DRUSH_YML_SUBSCRIPTION_FILE_CONFIGURATION}" ]; then

    raise FileNotFound "[sites_acquia_drush_load_configurations] File ${_SITES_ACQUIA_DRUSH_YML_SUBSCRIPTION_FILE_CONFIGURATION} not found!"

  else

    eval $(yml_loader ${_SITES_ACQUIA_DRUSH_YML_SUBSCRIPTION_FILE_CONFIGURATION} "_")

  fi

  local _SITES_ACQUIA_DRUSH_YML_SUBSCRIPTION_FILE_SUBSITE="${SF_SCRIPTS_HOME}/config/${_SITES_ACQUIA_DRUSH_SUBSCRIPTION:-}.yml"

  if [ ! -f "${_SITES_ACQUIA_DRUSH_YML_SUBSCRIPTION_FILE_SUBSITE}" ]; then

    raise FileNotFound "[sites_acquia_drush_load_configurations] Missing configuration file ${_SITES_ACQUIA_DRUSH_YML_SUBSCRIPTION_FILE_SUBSITE}"

  else

    eval $(yml_loader ${_SITES_ACQUIA_DRUSH_YML_SUBSCRIPTION_FILE_SUBSITE} "_")

  fi

  sites_acquia_drush_load_acquia_sites

  sites_acquia_drush_load_yml_sites

}

function sites_acquia_drush_load_analyze_sites() {

  out_warning "Analyzing sites" 1

  _SITES_ACQUIA_DRUSH_SITES=$(${_GREP} -Fx -f ${_SITES_ACQUIA_DRUSH_ACQUIA_FILE} ${_SITES_ACQUIA_DRUSH_YML_FILE}) && true

  if [ -n "${_SITES_ACQUIA_DRUSH_SITES}" ]; then

    out_success "Will run command on the sites:" 1
    echo ${_SITES_ACQUIA_DRUSH_SITES}

  else

    raise MissingRequiredConfig "[sites_acquia_drush_load_analyze_sites] No sites were found from config files that matched in Acquia"

  fi

  _SITES_ACQUIA_DRUSH_ACQUIA_SITES_ONLY=$(${_GREP} -Fxv -f ${_SITES_ACQUIA_DRUSH_YML_FILE} ${_SITES_ACQUIA_DRUSH_ACQUIA_FILE}) && true

  if [[ -n "${_SITES_ACQUIA_DRUSH_ACQUIA_SITES_ONLY}" ]]; then

    out_danger "Sites found only in Acquia:" 1
    echo "${_SITES_ACQUIA_DRUSH_ACQUIA_SITES_ONLY}"
    out_info "Commands will not be ran in them. Consider removing from configuration files"

  fi

  _SITES_ACQUIA_DRUSH_YML_SITES_ONLY=$(${_GREP} -Fxv -f ${_SITES_ACQUIA_DRUSH_ACQUIA_FILE} ${_SITES_ACQUIA_DRUSH_YML_FILE}) && true

  if [[ -n "${_SITES_ACQUIA_DRUSH_YML_SITES_ONLY}" ]]; then

    out_danger "Sites found only in YML:" 1
    echo "${_SITES_ACQUIA_DRUSH_YML_SITES_ONLY}"
    out_info "Commands will not be ran in them. Consider removing from configuration files"

  fi

}

function sites_acquia_drush_execute_command() {

  if [[ "${_SITES_ACQUIA_DRUSH_ACQUIA_SITES_ONLY}" != "" ]] || [[ "${_SITES_ACQUIA_DRUSH_YML_SITES_ONLY}" != "" ]]; then

    out_notify "Site analysis complete" "Site analysis complete, please choose how to proceed."
    out_confirm "Site analysis complete, please confirm if you want to proceed. Continue?" 1 && true

    if [ $? -eq 1 ]; then

      return 0

    fi

  fi

  out_warning "Running drush command [ ${_SITES_ACQUIA_DRUSH_COMMANDS} ] in [ ${_SITES_ACQUIA_DRUSH_SUBSCRIPTION}.${_SITES_ACQUIA_DRUSH_ENVIRONMENT} ]" 1

  for _SUBSITE in ${_SITES_ACQUIA_DRUSH_SITES}; do

    out_info "Running command on [ ${_SUBSITE} ]" 1
    drush_command_on_subsite_from_acquia ${_SITES_ACQUIA_DRUSH_SUBSCRIPTION} ${_SITES_ACQUIA_DRUSH_ENVIRONMENT} ${_SUBSITE} ${_SITES_ACQUIA_DRUSH_COMMANDS}
    out_check_status $? "Drush command runned successfully" "Drush command failed"

  done

}
