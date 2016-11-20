#!/usr/bin/env bash

# Load All susbcriptions
function file_server_load_subscriptions() {

  for _SUBSCRIPTION in ${_FILE_SERVER_GET_ALL_SUBSCRIPTION}; do

    file_server_subscription_load_configurations ${_SUBSCRIPTION}

  done

}

# Load configure variable session in actual subscription
function file_server_subscription_load_configurations() {

  local _SUBSCRIPTION=${1:-}
  if [ -z ${_SUBSCRIPTION:-} ]; then

    out_warning "[file_server_subscription_load_configurations] Please provide a valid subscription"
    continue;

  fi

  local _LOCAL_SETUP_YML_SUBSCRIPTION_FILE_SUBSITES="${SF_SCRIPTS_HOME}/config/${_SUBSCRIPTION,,}.yml"
  local _LOCAL_SETUP_YML_SUBSCRIPTION_FILE_SUBSITES_DEV="${SF_SCRIPTS_HOME}/config/${_SUBSCRIPTION,,}_dev.yml"

  if [ -f "${_LOCAL_SETUP_YML_SUBSCRIPTION_FILE_SUBSITES}" ]; then

    yml_parse ${_LOCAL_SETUP_YML_SUBSCRIPTION_FILE_SUBSITES} "_"

  fi

  if [ -f "${_LOCAL_SETUP_YML_SUBSCRIPTION_FILE_SUBSITES_DEV}" ]; then

    yml_parse ${_LOCAL_SETUP_YML_SUBSCRIPTION_FILE_SUBSITES_DEV} "_"

  fi

  # Global folder alternate conform alter subscriptions
  _FILE_SERVER_NFS_FOLDER="${_FILE_SERVER_FILE_DESTINATION}/${_SUBSCRIPTION,,}/sites"

  _LOCAL_SETUP_GET_SITES=$(file_server_convert_site_name ${_SUBSCRIPTION,,})

  file_server_download_files ${_SUBSCRIPTION}
  if [ -d "${_FILE_SERVER_NFS_FOLDER}" ]; then
    sudo ${_CHMOD} -R 777 "${_FILE_SERVER_FILE_DESTINATION}/${_SUBSCRIPTION,,}"
  fi
  file_server_check_unused_folders

}

function file_server_convert_site_name() {

  local _SUBSCRIPTION=${1:-}
  if [ -z ${_SUBSCRIPTION:-} ]; then

    out_warning "[file_server_convert_site_name] Please provide a valid subscription"
    continue;

  fi

  local _FILE_SERVER_SITES_TEMP=$(subscription_configuration_get_sites ${_SUBSCRIPTION})

  local _FILES_SERVER_CONVERT_NAMES_SITES=""
  for _CONVERT_SITE_NAME in ${_FILE_SERVER_SITES_TEMP}; do

    local _LOCAL_SETUP_SUBSITE_REAL_NAME=$(site_configuration_get_subsite_name ${_CONVERT_SITE_NAME} ${_SUBSCRIPTION})
    local _FILES_SERVER_CONVERT_NAMES_SITES="${_LOCAL_SETUP_SUBSITE_REAL_NAME} ${_FILES_SERVER_CONVERT_NAMES_SITES}"

  done

  echo ${_FILES_SERVER_CONVERT_NAMES_SITES[@]}


}
