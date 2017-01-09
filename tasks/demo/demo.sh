#!/usr/bin/env bash

# 1. Run without any sudo
# 2. Make sure the script can setup a brand new site/subs without manual work
# 3. Manual confs done in server:
# - chmod u+s /var/log
# - chmod 775 /var/www/html
# - added ubuntu to root group
# - chmod u+s /etc/apache2/sites-available
#====================================================================================================#

function demo_run() {

  demo_load_configurations "${@}"

  demo_execute

}

function demo_usage() {

  if [ ${#} != 1 ]; then

    out_usage "${_SCRIPT_ALIAS} demo <param>" 1
    return 1

  else

    return 0

  fi

}
