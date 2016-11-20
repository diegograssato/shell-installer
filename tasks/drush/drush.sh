#!/usr/bin/env bash

import docker yml_loader drush
import os_command os_grunt site_configuration subscription_configuration

function drush_run() {

  # 1. Load basics configurations and validate parameters
  drush_load_configurations "${@}"

  # 2. Execute task in docker
  drush_execute_task

}

function drush_usage() {

  if [ ${#} -lt 3 ]; then

    out_usage "sf drush <site> <subscription> <command>" 1
    return 1

  else

    return 0

  fi

}
