#!/usr/bin/env bash

function file_server_check_unused_folders() {

  if [ ! -d ${_FILE_SERVER_NFS_FOLDER:-} ]; then

    out_warning "[file_server_check_unused_folders] Folder not found ${_FILE_SERVER_NFS_FOLDER:-}"
    continue;

  fi


  out_info "Checking unused folders in ${_FILE_SERVER_NFS_FOLDER}" 1
  #Get all folder from subscription
  local _LOCAL_SETUP_SUBSITES_IN_PLATFORM=$(find ${_FILE_SERVER_NFS_FOLDER} -maxdepth 1 -mindepth 1 -type d -printf '%f\n')

  for _SUBSITE_IN_PLATFORM in ${_LOCAL_SETUP_SUBSITES_IN_PLATFORM}; do

    if (file_server_check_subsite_not_exists ${_SUBSITE_IN_PLATFORM}); then

      filse_server_remove_subsite_not_used ${_SUBSITE_IN_PLATFORM}

    fi

  done

}

function file_server_check_subsite_not_exists() {

  local _SUBSITE=${1:-}
  if [ -z ${_SUBSITE:-} ]; then

    out_warning "[file_server_check_subsite_not_exists] Please provide a valid site"
    continue;

  fi

  if (in_list? ${_SUBSITE} "${_LOCAL_SETUP_GET_SITES[@]}"); then

    return 1

  else

    return 0

  fi

}

function filse_server_remove_subsite_not_used() {

  local _SUBSITE=${1:-}
  if [ -z ${_SUBSITE:-} ]; then

    out_warning "[filse_server_remove_subsite_not_used] Please provide a valid site"
    continue;

  fi

  out_warning "Folder unused: ${_FILE_SERVER_NFS_FOLDER}/${_SUBSITE}"
  ${_RMF} "${_FILE_SERVER_NFS_FOLDER}/${_SUBSITE_IN_PLATFORM}"
  out_check_status $? "Folder removed successfully" "Error while on remove folder"

}


function file_server_download_files() {

  local _SUBSCRIPTION=${1:-}
  if [ -z ${_SUBSCRIPTION:-} ]; then

    out_warning "[file_server_download_files] Please provide a valid subscription"
    continue;

  fi

  for _SUBSITE in ${_LOCAL_SETUP_GET_SITES}; do

    local _NFS_SITE_FOLDER="${_FILE_SERVER_NFS_FOLDER}/${_SUBSITE}/files"
    site_configuration_files_download ${_SUBSCRIPTION,,} 'test' ${_SUBSITE} ${_NFS_SITE_FOLDER} "true"
    sudo ${_CHMOD} -R 777 "${_FILE_SERVER_NFS_FOLDER}"

  done


}
