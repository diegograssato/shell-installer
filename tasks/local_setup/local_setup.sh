#!/usr/bin/env bash
#TODO
# 1. Run without any sudo
# 2. Make sure the script can setup a brand new site/subs without manual work
# 3. Manual confs done in server:
# - chmod u+s /var/log
# - chmod 775 /var/www/html
# - added ubuntu to root group
# - chmod u+s /etc/apache2/sites-available
#====================================================================================================#

import acquia database docker grunt git metrics slack apache dns yml_loader
import os_nfs_server site_configuration subscription_configuration

function local_setup_run() {

  # 1. Load basics configurations and validate parameters
  local_setup_load_configurations "${@}"
  local_setup_metrics_init
  metrics_touch

  # 2. Clone/Update repositories, subscription and site
  local_setup_platform
  metrics_touch
  local_setup_site_repository
  metrics_touch

  # 3. Create local configs, vhosts, settings.local.php and sites.local.php
  local_setup_local_configs
  metrics_touch

  # 4. Check if docker is stated, if not started run docker-compose restart
  local_setup_docker_check_status
  metrics_touch

  # 5. Move local database to qa database
  local_setup_database
  metrics_touch

  # 6. Clean site cache
  local_setup_cache_clear
  metrics_touch

  # 7. List all url sites
  local_setup_post_execution
  metrics_touch

}

function local_setup_usage() {

  if [ ${#} -lt 2 ] || [ ${#} -gt 6 ]; then

    out_usage "sf local_setup <site> <subscription> (<from_environment>:test) (<sync_db:false>) (<db_type>:citdev) (<sync subsite files:true>)" 1
    return 1

  else

    return 0

  fi

}

function local_setup_configurations() {

  # First check configurations
  if [ ! -f "${SF_SCRIPTS_HOME}/config/${_TASK_NAME}_config.bash" ]; then

    out_missing_configurations "Please copy ${SF_SCRIPTS_HOME}/tasks/${_TASK_NAME}/${_TASK_NAME}_config.bash.dist to ${SF_SCRIPTS_HOME}/config/${_TASK_NAME}_config.bash and configure the optional arguments." 1

    return 1;

  fi

}
