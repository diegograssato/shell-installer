#!/usr/bin/env bash

import acquia git slack metrics os_grunt yml_loader
import site_configuration subscription_configuration

function mtp_run() {

  # Load basics configurations and validate parameters
  mtp_load_configurations "${@}"
  mtp_metrics_init
  metrics_touch

  mtp_load_repository
  metrics_touch

  mtp_load_commits
  metrics_touch

  mtp_database_backup
  metrics_touch

  mtp_generate_release
  metrics_touch

  mtp_apply_commits
  metrics_touch

  mtp_grunt_workflow
  metrics_touch

  mtp_generate_release_tag
  metrics_touch

  mtp_push_code
  metrics_touch

  mtp_active_code
  metrics_touch

  mtp_clear_caches
  metrics_touch

  mtp_rebase_master
  metrics_touch

  mtp_post_execution
  metrics_touch

}

function mtp_usage() {

  if [ ${#} -lt 2 ] || [ ${#} -gt 5 ]; then

    out_usage "sf mtp <ticket id> <subscription> (<mtp_interactive>:false) (<mtp_clear_cache>:true) (<mtp_generate_backup>:true)" 1
    return 1

  else

    return 0

  fi

}
