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

function file_server_run() {

  # 1. Load basics configurations and validate parameters
  file_server_load_configurations 

}
