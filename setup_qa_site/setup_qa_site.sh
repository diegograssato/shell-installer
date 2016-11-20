#!/usr/bin/env bash
#TODO
# Run without any sudo
# Make sure the script can setup a brand new site/subs without manual work
#====================================================================================================#

import acquia database git slack apache dns yml_loader
import site_configuration subscription_configuration

function setup_qa_site_run() {

  # 1. Load basics configurations and validate parameters
  setup_qa_site_load_configurations "${@}"

  # 2. Clone/Update repositories, subscription and site
  setup_qa_site_load_repositories

  # 3. Create/Update DNS for new site
  setup_qa_site_dns

  # 4. Create local  vhosts
  setup_qa_site_create_subsite_vhost

}

function setup_qa_site_usage() {

  if [ ! ${#} -eq 2 ] && [ ! ${#} -eq 3 ]; then

    out_usage "./main.sh setup_qa_site <site> <subscription>" 1
    return 1

  else

    return 0

  fi

}
