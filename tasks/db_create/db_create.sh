#!/usr/bin/env bash

function db_create_run() {

  # 1. Load basics configurations and validate parameters
  db_create_load_configurations "${@}"

  # 2. Create database
  db_create_create_database

}

function db_create_usage() {

  if [ ! ${#} -eq 2 ]; then

    out_usage "sf db_create <db_name> <server>" 1
    return 1

  else

    return 0

  fi

}

function db_create_configurations() {

  # First check configurations
  if [ ! -f "${SF_SCRIPTS_HOME}/config/${_TASK_NAME}_config.bash" ]; then

    out_missing_configurations "Please copy ${SF_SCRIPTS_HOME}/tasks/${_TASK_NAME}/${_TASK_NAME}_config.bash.dist to ${SF_SCRIPTS_HOME}/config/${_TASK_NAME}_config.bash and configure the optional arguments." 1

    return 1;

  fi

}
