#!/usr/bin/env bash

function mts_load_subsite_repository() {

  local _MTS_SUBSITE_REPO=$(site_configuration_get_subsite_repo ${_MTS_SUBSITE} ${_MTS_SUBSCRIPTION})

  if [ -z ${_MTS_SUBSITE_REPO} ]; then

    raise MissingRequiredConfig "[mts_load_repositories] ${_MTS_SUBSITE} repository not found. Please check the file ${_MTS_SUBSCRIPTION}.yml"

  fi

  if [ ! -d "${_MTS_PLATFORM_SUBSITES_PATH}" ]; then

    ${_MKDIR} -p ${_MTS_PLATFORM_SUBSITES_PATH}

  fi

  git_load_repositories ${_MTS_SUBSITE_REPO} ${_MTS_SUBSITE_BRANCH} ${_MTS_SUBSITE_PATH}

}

function mts_load_acquia_repository () {

  local _MTS_ACQUIA_REPO=$(subscription_configuration_get_acquia_repo ${_MTS_SUBSCRIPTION})

  if [ -z ${_MTS_ACQUIA_REPO} ]; then

    raise MissingRequiredConfig "[mts_load_repositories] Acquia repository not found for subscription ${_MTS_SUBSCRIPTION}. Please check the configuration file subscription.yml"

  fi

  git_load_repositories ${_MTS_ACQUIA_REPO} ${_MTS_ACQUIA_REPO_RESOURCE} ${_MTS_ACQUIA_SUBSCRIPTION_PATH}

}

function mts_abort() {

  _MTS_ABORT_TYPE=${1:-}
  _MTS_ABORT_MESSAGE=${2:-}

  if [ ${_MTS_ABORT_TYPE} == "ApplyPatchError" ]; then

    git_abort_am ${_MTS_ACQUIA_SUBSCRIPTION_PATH}

  fi

  git_reset_repository ${_MTS_ACQUIA_SUBSCRIPTION_PATH}
  git_clean_repository ${_MTS_ACQUIA_SUBSCRIPTION_PATH}

  raise ${_MTS_ABORT_TYPE} "[mts_abort] ${_MTS_ABORT_MESSAGE}"

}
