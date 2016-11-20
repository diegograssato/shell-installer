#!/usr/bin/env bash

function ctech_deploy_load_subsite_repository() {

  local _CTECH_DEPLOY_SUBSITE_REPO=$(site_configuration_get_master_repo_url ${_CTECH_DEPLOY_SUBSITE} ${_CTECH_DEPLOY_SUBSCRIPTION})

  if [ -z ${_CTECH_DEPLOY_SUBSITE_REPO} ]; then

    raise MissingRequiredConfig "[ctech_deploy_load_subsite_repository] ${_CTECH_DEPLOY_SUBSITE} repository not found. Please check the file ${_CTECH_DEPLOY_SUBSCRIPTION}.yml"

  fi

  git_load_repositories ${_CTECH_DEPLOY_SUBSITE_REPO} ${_CTECH_DEPLOY_SUBSITE_BRANCH} ${_CTECH_DEPLOY_SUBSITE_PATH}

}

function ctech_deploy_load_acquia_repository () {

  local _CTECH_DEPLOY_ACQUIA_REPO=$(subscription_configuration_get_acquia_repo ${_CTECH_DEPLOY_SUBSCRIPTION})

  if [ -z ${_CTECH_DEPLOY_ACQUIA_REPO} ]; then

    raise MissingRequiredConfig "[ctech_deploy_load_acquia_repository] Acquia repository not found for subscription ${_CTECH_DEPLOY_SUBSCRIPTION}. Please check the configuration file subscription.yml"

  fi

  git_load_repositories ${_CTECH_DEPLOY_ACQUIA_REPO} ${_CTECH_DEPLOY_ACQUIA_REPO_RESOURCE} ${_CTECH_DEPLOY_ACQUIA_SUBSCRIPTION_PATH}

}

function ctech_deploy_abort_script() {

  _CTECH_DEPLOY_ABORT_TYPE=${1:-}
  _CTECH_DEPLOY_ABORT_MESSAGE=${2:-}

  out_danger "Patch failed to apply, please manually perform the deployment" 1

  git_reset_repository ${_CTECH_DEPLOY_ACQUIA_SUBSCRIPTION_PATH}
  git_clean_repository ${_CTECH_DEPLOY_ACQUIA_SUBSCRIPTION_PATH}

  slack_notify ":no_entry_sign: CTECH deployment failed for ${_CTECH_DEPLOY_TICKET_ID} in ${_CTECH_DEPLOY_SUBSITE}@${_CTECH_DEPLOY_SUBSCRIPTION}.${_CTECH_DEPLOY_ENVIRONMENT} [ ${_CTECH_DEPLOY_ABORT_TYPE} - ${_CTECH_DEPLOY_ABORT_MESSAGE} ]"

  raise ${_CTECH_DEPLOY_ABORT_TYPE} "[ctech_deploy_abort_script] ${_CTECH_DEPLOY_ABORT_MESSAGE}"

}
