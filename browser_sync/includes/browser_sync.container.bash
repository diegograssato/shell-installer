#!/usr/bin/env bash

function browser_sync_stop_container() {

  if ( docker_container_exists ${_BROWSER_SYNC_CONTAINER} ); then

    out_warning "Container ${_BROWSER_SYNC_CONTAINER} is running" 1

    out_info "Stoping container ${_BROWSER_SYNC_CONTAINER}"
    docker_stop ${_BROWSER_SYNC_CONTAINER}
    out_check_status $? "Container ${_BROWSER_SYNC_CONTAINER} stoped" "Error while stoping container ${_BROWSER_SYNC_CONTAINER}" 1

    out_info "Removing container ${_BROWSER_SYNC_CONTAINER}"
    docker_rm "${_BROWSER_SYNC_CONTAINER}"
    out_check_status $? "Container ${_BROWSER_SYNC_CONTAINER} removed" "Error while removing container ${_BROWSER_SYNC_CONTAINER}" 1

  fi

}
