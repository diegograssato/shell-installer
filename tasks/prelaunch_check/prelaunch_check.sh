#!/usr/bin/env bash

import acquia drush git error_logs metrics slack
import os_grunt os_utils

function prelaunch_check_run() {

  # 1. Load basics configurations and validate parameters
  prelaunch_check_load_configurations "${@}"
  metrics_add ${_PRELAUNCH_CHECK_SUBSITE}
  metrics_add ${_PRELAUNCH_CHECK_SUBSCRIPTION}
  metrics_touch

  # 2. Load Vendor and Platform Repositories
  prelaunch_check_load_repository
  metrics_touch

  # 3. Check UPDB, Janrain Entitlement, etc
  prelaunch_check_database_configs
  metrics_touch

  # 4. Check if Grunt runs successfully
  prelaunch_check_grunt
  metrics_touch

  # 5. Check features like sitemal.xml and robots.txt
  prelaunch_check_functionality
  metrics_touch

  # 6. Checking for large non-optimized images > 400KB
  prelaunch_check_large_images
  metrics_touch

  # 7. List diffs between jjbos profile
  prelaunch_check_diff_platform
  metrics_touch

  # 8. Check server logs for recent errors
  prelaunch_check_logs

  # TODO check for custom files added to the root folder, like googleaae6afffdcf3988a.html

}

function prelaunch_check_usage() {

  if [ ! ${#} -eq 3 ]; then

    out_usage "sf prelaunch_check <site> <subscription> <site_url>" 1
    return 1

  else

    return 0

  fi

}
