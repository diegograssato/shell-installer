#!/usr/bin/env bash


function file_server_load_configurations() {

  local _LOCAL_SETUP_YML_SUBSCRIPTION_FILE_CONFIGURATION="${SF_SCRIPTS_HOME}/config/subscriptions.yml"
  local _LOCAL_SETUP_YML_SUBSCRIPTION_FILE_CONFIGURATION_DEV="${SF_SCRIPTS_HOME}/config/subscriptions_dev.yml"

  if [ ! -f "${_LOCAL_SETUP_YML_SUBSCRIPTION_FILE_CONFIGURATION}" ]; then

    raise FileNotFound "[local_setup_load_configurations] File ${_LOCAL_SETUP_YML_SUBSCRIPTION_FILE_CONFIGURATION} not found!"

  else

    yml_parse ${_LOCAL_SETUP_YML_SUBSCRIPTION_FILE_CONFIGURATION} "_"
    # Added second parser from YAML, more complex and complete;
    yay ${_LOCAL_SETUP_YML_SUBSCRIPTION_FILE_CONFIGURATION} "_"

  fi

  out_warning "Loading configurations" 1

  _FILE_SERVER_GET_ALL_SUBSCRIPTION=$(subscription_configuration_get_all_subscriptions)
  file_server_load_subscriptions

}
