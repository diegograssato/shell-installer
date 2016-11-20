#!/usr/bin/env bash

import site_configuration subscription_configuration
import drush yml_loader

function sites_acquia_drush_run() {

  # 1. Load basics configurations and validate parameters
  sites_acquia_drush_load_configurations "${@}"

  # 2. Analyzing sites found in Acquia and configurations
  sites_acquia_drush_load_analyze_sites

  # 3. Execute task in docker
  sites_acquia_drush_execute_command

}

function sites_acquia_drush_usage() {

  if [ ${#} -lt 3 ]; then

    out_usage "sf sites_acquia_drush <subscription> <environment> \"<command>\"" 1
    return 1

  else

    return 0

  fi

}
