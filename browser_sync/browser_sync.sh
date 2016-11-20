#!/usr/bin/env bash

import docker git yml_loader
import os_grunt site_configuration subscription_configuration

function browser_sync_run() {

  # 1. Load basics configurations and validate parameters
  browser_sync_load_configurations "${@}"

  browser_sync_check_docker_image

  browser_sync_execute

}

function browser_sync_usage() {

  if [ ${#} -lt 1 ]; then

    out_usage "sf browser_sync <site> <subscription> (<site_url>)" 1
    out_usage "or"
    out_usage "sf browser_sync stop"

    return 1

  else

    return 0

  fi

}

function browser_sync_configurations() {

  # First check configurations
  if [ ! -f "${SF_SCRIPTS_HOME}/config/${_TASK_NAME}_config.bash" ]; then

    out_missing_configurations "Please copy ${SF_SCRIPTS_HOME}/tasks/${_TASK_NAME}/${_TASK_NAME}_config.bash.dist to ${SF_SCRIPTS_HOME}/config/${_TASK_NAME}_config.bash and configure the optional arguments." 1

    return 1;

  fi

}

# TODO: Test case
# sf local_setup mcneil_us jnjlegosgamma
# sf browser_sync mcneil_us jnjlegosgamma
# sf browser_sync stop
