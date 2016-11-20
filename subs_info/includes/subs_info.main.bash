#!/usr/bin/env bash

function subs_info_load_configurations() {

  if [ -z ${1:-} ]; then

    _SUBS_INFO_REPORT_FILE="/tmp/subs_info.report"

  else

    _SUBS_INFO_REPORT_FILE=${1}

  fi

  filesystem_delete_file ${_SUBS_INFO_REPORT_FILE}

  filesystem_create_file ${_SUBS_INFO_REPORT_FILE}

  local _SUBS_INFO_YML_SUBSCRIPTION_FILE_CONFIGURATION="${SF_SCRIPTS_HOME}/config/subscriptions.yml"

  if [ ! -f "${_SUBS_INFO_YML_SUBSCRIPTION_FILE_CONFIGURATION}" ]; then

    raise FileNotFound "[local_setup_load_configurations] File ${_SUBS_INFO_YML_SUBSCRIPTION_FILE_CONFIGURATION} not found!"

  else

    yml_parse ${_SUBS_INFO_YML_SUBSCRIPTION_FILE_CONFIGURATION} "_"
    # Added second parser from YAML, more complex and complete;
    yay ${_SUBS_INFO_YML_SUBSCRIPTION_FILE_CONFIGURATION} "_"

  fi

  _SUBS_INFO_GET_ALL_SUBSCRIPTION=$(subscription_configuration_get_prod_subscriptions)

  for _SUBSCRIPTION in ${_SUBS_INFO_GET_ALL_SUBSCRIPTION}; do

    local _SUBS_INFO_YML_SUBSCRIPTION_FILE_SUBSITES="${SF_SCRIPTS_HOME}/config/${_SUBSCRIPTION,,}.yml"

    if [ -f "${_SUBS_INFO_YML_SUBSCRIPTION_FILE_SUBSITES}" ]; then

      out_info "Loading configuration file for production subscription [${_SUBSCRIPTION}]"

      yml_parse ${_SUBS_INFO_YML_SUBSCRIPTION_FILE_SUBSITES} "_"

    fi

  done

}

function subs_info_check_subscriptions() {

  local _ENVS="test prod"

  for _SUBSCRIPTION in ${_SUBS_INFO_GET_ALL_SUBSCRIPTION}; do

    local _SUBS_INFO_SAMPLE_SITE=""

    echo "${_SUBSCRIPTION,,}:" >> ${_SUBS_INFO_REPORT_FILE}

    out_warning "Processing ${_SUBSCRIPTION,,}" 1

    subs_info_get_live_sites ${_SUBSCRIPTION,,}

    subs_info_get_subscription_region ${_SUBSCRIPTION,,}

    subs_info_get_subscription_name ${_SUBSCRIPTION,,}

    for _ENV in ${_ENVS}; do

      echo "  ${_ENV}:" >> ${_SUBS_INFO_REPORT_FILE}

      out_warning "Processing ${_SUBSCRIPTION,,} ${_ENV}" 1

      subs_info_get_sites ${_SUBSCRIPTION,,} ${_ENV}

      subs_info_get_platform_version ${_SUBSCRIPTION,,} ${_ENV}

      subs_info_get_drupal_version ${_SUBSCRIPTION,,} ${_ENV}

    done

  done

}

function subs_info_post_execution() {

  out_success "Configurations created at [${_SUBS_INFO_REPORT_FILE}]" 1

}
