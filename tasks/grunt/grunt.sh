#!/usr/bin/env bash
#===========================================================#

import docker git metrics yml_loader
import os_grunt site_configuration subscription_configuration

function grunt_run() {

  # 1. Load basics configurations and validate parameters
  grunt_load_configurations "${@}"
  metrics_add ${_GRUNT_SUBSITE}
  metrics_add ${_GRUNT_SUBSCRIPTION}
  metrics_touch

  # 2. Execute task in docker
  grunt_execute_task "${@}"
  metrics_touch

}

function grunt_usage() {

  if [ ${#} -lt 2 ]; then

    out_usage "sf grunt <site> <subscription> (<grunt_parameters>)" 1
    return 1

  else

    return 0

  fi

}
