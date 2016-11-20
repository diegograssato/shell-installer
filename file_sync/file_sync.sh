#!/usr/bin/env bash
#TODO
#====================================================================================================#

import acquia
import site_configuration

function file_sync_run() {

  # 1. Load basics configurations and validate parameters
  file_sync_load_configurations "${@}"
  
  file_sync_run_operations

}

function file_sync_usage() {

  if [ ! ${#} -eq 2 ] && [ ! ${#} -eq 4 ] && [ ! ${#} -eq 5 ]; then

    out_usage "sf file_sync <dl|up> <subscription> <environment> <sub site> (<path to sites folder:>)" 1
    return 1

  else

    return 0

  fi

}
