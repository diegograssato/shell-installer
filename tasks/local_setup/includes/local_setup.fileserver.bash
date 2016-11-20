#!/usr/bin/env bash

function local_setup_configuration_subsite_files() {

  local _LOCAL_SETUP_SUBSITE_FILES="${_LOCAL_SETUP_SUBSCRIPTION_WEB_SITE_REAL_PATH}/${_LOCAL_SETUP_SUBSITE_REAL_NAME}/files"
  local _LOCAL_SETUP_SUBSITE_NFS_FILES="$_LOCAL_SETUP_NFS_FILES/${_LOCAL_SETUP_SUBSCRIPTION}/sites/$_LOCAL_SETUP_SUBSITE_REAL_NAME/files"

  if [ ${_LOCAL_SETUP_SYNC_FILES} == 'true' ]; then

    if (os_nfs_server_fileserver_status && os_nfs_server_fileserver_configure_remote_server_in_fstab); then

      out_info "Creating link from files folder: ${_LOCAL_SETUP_SUBSITE_FILES}" 1
      if [ -L ${_LOCAL_SETUP_SUBSITE_FILES} ] && [ -d "${_LOCAL_SETUP_SUBSITE_NFS_FILES}" ]; then

        out_warning "Removing old link ${_LOCAL_SETUP_SUBSITE_FILES}"
        ${_UNLINK} ${_LOCAL_SETUP_SUBSITE_FILES}

      fi

      if [ -d ${_LOCAL_SETUP_SUBSITE_FILES} ] && [ -d "${_LOCAL_SETUP_SUBSITE_NFS_FILES}" ]; then

        out_warning "Removing old folder ${_LOCAL_SETUP_SUBSITE_FILES}"
        ${_RMF} ${_LOCAL_SETUP_SUBSITE_FILES}

      fi

      if [ -d "${_LOCAL_SETUP_SUBSITE_NFS_FILES}" ]; then

        ${_LN} -s "../../../../../files/${_LOCAL_SETUP_SUBSCRIPTION,,}/sites/${_LOCAL_SETUP_SUBSITE_REAL_NAME}/files" ${_LOCAL_SETUP_SUBSITE_FILES}
        out_check_status $? "Link created successfully" "Error on creating link from files"

      else

        out_warning "Subsite folder does not exist on files server. Downloading from Acquia" 1
        site_configuration_files_download ${_LOCAL_SETUP_SUBSCRIPTION} ${_LOCAL_SETUP_SUBSCRIPTION_ENVIRONMENT} ${_LOCAL_SETUP_SUBSITE_REAL_NAME} "${_LOCAL_SETUP_SUBSITE_FILES}" 1

      fi

    else

      out_warning "CI&T Files server is unreachable. Downloading from Acquia" 1
      site_configuration_files_download ${_LOCAL_SETUP_SUBSCRIPTION} ${_LOCAL_SETUP_SUBSCRIPTION_ENVIRONMENT} ${_LOCAL_SETUP_SUBSITE_REAL_NAME} "${_LOCAL_SETUP_SUBSITE_FILES}" 1

    fi

  else

    out_warning "Skipping files sync" 1

  fi

}
