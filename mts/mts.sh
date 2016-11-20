#!/usr/bin/env bash

import acquia git slack metrics os_grunt yml_loader
import site_configuration subscription_configuration

function mts_run() {

  # Load basics configurations and validate parameters
  mts_load_configurations "${@}"
  mts_metrics_init
  metrics_touch

  mts_load_repositories
  metrics_touch

  mts_load_commits
  metrics_touch

  mts_generate_patches
  metrics_touch

  mts_apply_commit_patches
  metrics_touch

  mts_grunt_workflow
  metrics_touch

  mts_push_code
  metrics_touch

  mts_tracking_stash
  metrics_touch

  mts_clear_caches
  metrics_touch

  mts_post_execution
  metrics_touch
}

function mts_usage() {

  if [ ${#} -lt 3 ] || [ ${#} -gt 4 ]; then

    out_usage "sf mts <site> <ticket id> <subscription> (<mts_interactive>:false)" 1
    return 1

  else

    return 0

  fi

}
