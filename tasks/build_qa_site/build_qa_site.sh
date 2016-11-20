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

import acquia database os_grunt git slack apache dns metrics yml_loader
import site_configuration subscription_configuration

function build_qa_site_run() {

  # 1. Load basics configurations and validate parameters
  build_qa_site_load_configurations "${@}"
  metrics_add ${_BUILD_QA_SITE_SUBSITE}
  metrics_add ${_BUILD_QA_SITE_SUBSCRIPTION}
  metrics_add ${_BUILD_QA_SITE_MOVE_DB}
  metrics_touch

  # 2. Clone/Update repositories, subscription and site
  build_qa_site_load_repositories # ok
  metrics_touch

  # 3. Rsync files from GIT to apache folder
  build_qa_site_apache_rsync "${@}" # ajustar
  metrics_touch

  # 4. Create local configs, vhosts, settings.local.php and sites.local.php
  build_qa_site_local_configs "${@}"
  metrics_touch

  # 5. Create files symbolic link
  build_qa_site_move_files "${@}"
  metrics_touch

  # 6. Move local database to qa database
  build_qa_site_database_move
  metrics_touch

  # 7. Update qa database settings
  build_qa_site_database_update_configs "${@}"
  metrics_touch

  # 8. Generate Grunt
  build_qa_site_compile_grunt "${@}"
  metrics_touch

  # 9. Print domains
  build_qa_site_list_domains "${@}"
  metrics_touch

}

function build_qa_site_usage() {

  if [ ! ${#} -eq 2 ] && [ ! ${#} -eq 3 ]; then

    out_usage "./main.sh build_qa_site <site> <subscription> (<move database>)" 1
    return 1

  else

    return 0

  fi

}
