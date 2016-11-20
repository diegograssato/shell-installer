#!/usr/bin/env bash

import acquia git slack metrics os_grunt yml_loader
import site_configuration subscription_configuration

function ctech_deploy_run() {

  # Load basics configurations and validate parameters
  ctech_deploy_load_configurations "${@}"
  metrics_add ${1}
  metrics_add ${2}
  metrics_touch

  ctech_deploy_load_repositories
  metrics_touch

  ctech_deploy_load_commits
  metrics_touch

  ctech_deploy_generate_patches
  metrics_touch

  ctech_deploy_prepare_release_branch
  metrics_touch

  ctech_deploy_apply_commit_patches
  metrics_touch

  ctech_deploy_grunt_workflow
  metrics_touch

  ctech_deploy_code
  metrics_touch

}

function ctech_deploy_usage() {

  if [ ! ${#} -eq 4 ]; then

    out_usage "sf ctech_deploy <subscription> <environment> <subsite> \"<ticket id>|...\"" 1
    return 1

  else

    return 0

  fi

}
