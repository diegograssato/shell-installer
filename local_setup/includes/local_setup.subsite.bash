#!/usr/bin/env bash

function local_setup_check_unused_folders() {


  if [ -z ${1:-} ]; then

    raise RequiredFolderNotFound "[local_setup_check_unused_folders] Folder not found ${1:-}"

  else

    local _LOCAL_SETUP_SUBSCRIPTION_WEB_SITE_PATH=${1:-}

  fi

  out_info "Checking unused folders in ${_LOCAL_SETUP_SUBSCRIPTION_WEB_SITE_PATH}" 1
  local _LOCAL_SETUP_SUBSITES_IN_PLATFORM=$(find ${_LOCAL_SETUP_SUBSCRIPTION_WEB_SITE_PATH} -maxdepth 1 -mindepth 1 -type d -printf '%f\n')
  for _SUBSITE_IN_PLATFORM in ${_LOCAL_SETUP_SUBSITES_IN_PLATFORM}; do

    #  check subsite is not used ${_SUBSITE_IN_PLATFORM}
    if (local_setup_check_subsite_not_exists ${_SUBSITE_IN_PLATFORM}); then

      local_setup_remove_subsite_not_used ${_SUBSITE_IN_PLATFORM}

    fi

  done

}

function local_setup_check_subsite_not_exists() {

  if [ -z ${1:-} ]; then

    raise RequiredParameterNotFound "[local_setup_check_subsite_not_exists] Please provide a valid site"

  else

    local _SUBSITE=${1}

  fi

  if (in_list? ${_SUBSITE} "${_LOCAL_SETUP_GET_SITES_SAME_VERSION[@]}"); then

    return 1

  else

    return 0

  fi

}

function local_setup_remove_subsite_not_used() {

  if [ -z ${1:-} ]; then

    raise RequiredParameterNotFound "[local_setup_remove_subsite_not_used] Please provide a valid site"

  else

    local _SUBSITE=${1}

  fi

  out_warning "Folder unused: ${_LOCAL_SETUP_SUBSCRIPTION_WEB_SITE_PATH}/${_SUBSITE}"
  # local _SUBSITE_REAL_NAME=$(site_configuration_get_subsite_name ${_SUBSITE} ${_SUBSCRIPTION})
  #
  # # Check old link detected
  # if [ -L "${_LOCAL_SETUP_SUBSCRIPTION_WEB_SITE_REAL_PATH}/${_SUBSITE_REAL_NAME}" ]; then
  #
  #   out_warning "Old link detected in [ ${_LOCAL_SETUP_SUBSCRIPTION_WEB_SITE_REAL_PATH}/${_SUBSITE_REAL_NAME} ]"
  #   ${_UNLINK} "${_LOCAL_SETUP_SUBSCRIPTION_WEB_SITE_REAL_PATH}/${_SUBSITE_REAL_NAME}"
  #   out_check_status $? "Unlinked successfully" "Error while on linking"
  #
  # fi

  ${_RMF} "${_LOCAL_SETUP_SUBSCRIPTION_WEB_SITE_PATH}/${_SUBSITE_IN_PLATFORM}"
  out_check_status $? "Folder removed successfully" "Error while on remove folder"

  #TODO Find all trahsed folders and remove all links trahseds, use "readlink"

}
