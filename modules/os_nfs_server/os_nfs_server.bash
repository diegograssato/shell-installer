#!/usr/bin/env bash

function os_nfs_server_fileserver_status() {

  if (nc -z ${_OS_NFS_SERVER_ADDRESS} 2049  >/dev/null 2>&1 && true); then

    return 0

  fi

  return 1

}

function os_nfs_server_fileserver_configure_remote_server_in_fstab() {

  if (os_nfs_server_fileserver_status); then

    local _OS_NFS_SERVER_FOLDER_REMOTE="${_OS_NFS_SERVER_ADDRESS}:/nfs/subscriptions"

    if ( ! ${_GREP} -q "${_OS_NFS_SERVER_FOLDER_REMOTE}" ${_OS_NFS_SERVER_FSTAB} ); then

        [ -d ${_OS_NFS_SERVER_NFS_FILES} ] || ${_MKDIR} -p ${_OS_NFS_SERVER_NFS_FILES}

        os_nfs_server_fileserver_configure_fstab ${_OS_NFS_SERVER_FOLDER_REMOTE}

        # In case of DNS/IP server change, it will also update the mount point
        local _OS_NFS_SERVER_IS_BUSY=$(os_nfs_server_fileserver_is_busy ${_OS_NFS_SERVER_NFS_FILES})
        if [ ${_OS_NFS_SERVER_IS_BUSY} == "nfs" ]; then

          sudo umount "${_OS_NFS_SERVER_NFS_FILES}" &> /dev/null

        fi

        sudo mount "${_OS_NFS_SERVER_NFS_FILES}" &> /dev/null

        if [ "$?" == "0" ]; then
          # return true
          return 0

        else
          # return false
          return 1

        fi

      else
        # return true
        return  0
    fi

  else

    # return false
    return 1

  fi

}


function os_nfs_server_fileserver_configure_fstab() {

  if [ -z ${1:-} ] &&  [ -d ${1:-} ]; then

    raise RequiredFolderNotFound "[os_nfs_server_fileserver_configure_fstab] Please provide a valid folder"

  else

    local _OS_NFS_SERVER_FOLDER_REMOTE=${1}

  fi

  out_info "Creating entry of FSTAB file" 1

  if (is_linux); then

    cat <<EOF | sudo tee -a ${_OS_NFS_SERVER_FSTAB} > /dev/null 2>&1

${_OS_NFS_SERVER_FOLDER_REMOTE} ${_OS_NFS_SERVER_NFS_FILES} nfs rsize=8192,wsize=8192,timeo=14,intr

EOF
    out_check_status $? "FSTAB entry created successfully" "Error while on create entry FSTAB file"

  elif (is_mac); then

    cat <<EOF | sudo tee -a ${_OS_NFS_SERVER_FSTAB} > /dev/null 2>&1

${_OS_NFS_SERVER_FOLDER_REMOTE} ${_OS_NFS_SERVER_NFS_FILES} nfs rsize=8192,wsize=8192,timeo=14,resvport

EOF
    out_check_status $? "FSTAB entry created successfully" "Error while on create entry FSTAB file"

  fi

}

function os_nfs_server_fileserver_is_busy() {

  local _OS_NFS_SERVER_FOLDER_REMOTE="${1}"
  local _OS_NFS_SERVER_FOLDER_REMOTE_CHECK_IN_USE=$(stat --file-system --format=%T ${_OS_NFS_SERVER_FOLDER_REMOTE})
  echo ${_OS_NFS_SERVER_FOLDER_REMOTE_CHECK_IN_USE}

}
