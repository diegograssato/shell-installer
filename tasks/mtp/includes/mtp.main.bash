#!/usr/bin/env bash

function mtp_load_configurations() {

  _MTP_TICKET_ID=${1^^}
  _MTP_TICKETS="$(echo ${_MTP_TICKET_ID}| tr "|" " ")"

  is_empty_validate "${_MTP_TICKET_ID}" "ticket"

  _MTP_SUBSCRIPTION=${2:-}
  is_empty_validate "${_MTP_SUBSCRIPTION}" "subscription"

  if [ -z ${3:-} ]; then

    _MTP_INTERACTIVE=false

  else

    _MTP_INTERACTIVE=${3}
    boolean_validate "${_MTP_INTERACTIVE}"

  fi

  if [ -z ${4:-} ]; then

    _MTP_CLEAR_CACHE=true

  else

    _MTP_CLEAR_CACHE=${4}
    boolean_validate "${_MTP_CLEAR_CACHE}"

  fi

  if [ -z ${5:-} ]; then

    _MTP_GENERATE_BACKUP=true

  else

    _MTP_GENERATE_BACKUP=${5}
    boolean_validate "${_MTP_GENERATE_BACKUP}"

  fi

  out_warning "Loading configurations" 1

  filesystem_create_folder ${_MTP_ACQUIA_WORKSPACE}

  local _MTP_YML_SUBSCRIPTION="${SF_SCRIPTS_HOME}/config/subscriptions.yml"
  local _MTP_YML_SITES="${SF_SCRIPTS_HOME}/config/${_MTP_SUBSCRIPTION:-}.yml"

  # Load Subscription YML
  if [ ! -f "${_MTP_YML_SUBSCRIPTION}" ]; then

    raise FileNotFound "[mtp_load_configurations] File ${_MTP_YML_SUBSCRIPTION} not found!"

  else

    yml_parse ${_MTP_YML_SUBSCRIPTION} "_"

  fi

  # Load Subsite YML
  if [ ! -f "${_MTP_YML_SITES}" ]; then

    raise FileNotFound "[mtp_load_configurations] Missing configuration file ${_MTP_YML_SITES}"

  else

    eval $(yml_loader ${_MTP_YML_SITES} "_")

  fi

  mtp_switch_env_dev

  out_info "Fetching active GIT resource in ${_MTP_SUBSCRIPTION}.${_MTP_ENVIRONMENT_TEST}" 1
  _MTP_ACQUIA_REPO_STAGE_RESOURCE=$(acquia_get_repository_active_resource ${_MTP_SUBSCRIPTION} ${_MTP_ENVIRONMENT_TEST})
  out_check_status $? "GIT resource found: ${_MTP_ACQUIA_REPO_STAGE_RESOURCE}" "Error while getting GIT resource"
  if [ -z ${_MTP_ACQUIA_REPO_STAGE_RESOURCE} ]; then

    raise MissingRequiredConfig "[mtp_load_configurations] GIT resource not found: ${_MTP_SUBSCRIPTION}.${_MTP_ENVIRONMENT_PROD}"

  fi
  #_MTP_ACQUIA_REPO_STAGE_RESOURCE="osops-uat-2.10"

  out_info "Fetching active GIT resource in ${_MTP_SUBSCRIPTION}.${_MTP_ENVIRONMENT_PROD}" 1
  _MTP_ACQUIA_REPO_PROD_RESOURCE=$(acquia_get_repository_active_resource ${_MTP_SUBSCRIPTION} ${_MTP_ENVIRONMENT_PROD})
  out_check_status $? "GIT resource found: ${_MTP_ACQUIA_REPO_PROD_RESOURCE}" "Error while getting GIT resource"

  if [ -z ${_MTP_ACQUIA_REPO_PROD_RESOURCE} ]; then

    raise MissingRequiredConfig "[mtp_load_configurations] GIT resource not found: ${_MTP_SUBSCRIPTION}.${_MTP_ENVIRONMENT_PROD}"

  fi
  #_MTP_ACQUIA_REPO_PROD_RESOURCE="build-7.x-2.10-2016-10-05"

  # Get paths_MTP_ACQUIA_REPO
  _MTP_ACQUIA_SUBSCRIPTION_PATH="${_MTP_ACQUIA_WORKSPACE}/${_MTP_SUBSCRIPTION}"
  _MTP_RUN_GIT_ACQUIA="${_GIT} -C ${_MTP_ACQUIA_SUBSCRIPTION_PATH}"
  _MTP_DRUSH_FROM_ACQUIA="${_DRUSH} @${_MTP_SUBSCRIPTION}.${_MTP_ENVIRONMENT_TEST}"

  #if is jenkins change container name
  if [ ! -z ${JENKINS_HOME+x} ]; then

    _MTP_DOCKER_CONTAINER=${SF_SCRIPTS_CONTAINER_CLI_NAME}

  else

    slack_notify "MTP for tickets ${_MTP_TICKETS} in ${_MTP_SUBSCRIPTION}"

  fi

}

function mtp_metrics_init() {

  metrics_add ${_MTP_TICKETS}
  metrics_add ${_MTP_SUBSCRIPTION}
  metrics_add ${_MTP_INTERACTIVE}
  metrics_add ${_MTP_CLEAR_CACHE}
  metrics_add ${_MTP_GENERATE_BACKUP}
  metrics_add ${_MTP_PLATFORM_CODE_MODIFICATION}

}

function mtp_load_repository() {

  out_warning "Loading acquia repository" 1
  mtp_load_acquia_repository

}

function mtp_load_commits() {

  out_warning "Loading commits for ticket ${_MTP_TICKETS}" 1

  # If MTS is on interactive mode, skip duplicate deploy validation for manual skip
  if (! ${_MTP_INTERACTIVE}); then

    mtp_validate_is_deployed

  fi

  _MTP_GIT_COMMITS=$(git_list_commits_by_filter ${_MTP_ACQUIA_REPO_STAGE_RESOURCE} ${_MTP_ACQUIA_SUBSCRIPTION_PATH} ${_MTP_TICKET_ID})

  if [[ -z ${_MTP_GIT_COMMITS} ]]; then

    raise InvalidParameter "[mtp_load_commits] There are no commits from this ticket ${_MTP_TICKET_ID}"

  fi

  mtp_list_commits

}

function mtp_database_backup() {

  if [[ ${_MTP_GENERATE_BACKUP} == "true" ]]; then

    local _MTP_SITES=$(mtp_get_sites)
    for _MTP_SITE in ${_MTP_SITES}; do

      local _MTP_DATABASES_AFFECTED=$(site_configuration_get_subsite_database_acquia ${_MTP_SITE} ${_MTP_SUBSCRIPTION})
      if [[ ! -z ${_MTP_DATABASES_AFFECTED} ]]; then

        out_warning "Backup database ${_MTP_DATABASES_AFFECTED} in ${_MTP_SUBSCRIPTION}.${_MTP_ENVIRONMENT_PROD}" 1
        acquia_database_backup ${_MTP_SUBSCRIPTION} ${_MTP_ENVIRONMENT_PROD} ${_MTP_DATABASES_AFFECTED}

      fi

    done

  fi

}

function mtp_generate_release() {

  out_warning "Generate release branch" 1
  mtp_create_release_branch

}

function mtp_apply_commits() {

  out_warning "Applying commits in ${_MTP_RELEASE_PLATFORM}" 1
  mtp_cherry_pick

}

function mtp_grunt_workflow() {

  out_warning "Running grunt on acquia repository" 1

  local _MTP_AFFECTED_THEMES=$(mtp_get_affected_themes)

  if [[ ! -z "${_MTP_AFFECTED_THEMES}" ]]; then

    mtp_run_grunt "${_MTP_AFFECTED_THEMES}"

  else

    out_info "There is no affected themes to run grunt" 1

  fi

}

function mtp_generate_release_tag() {

  out_warning "Generate release Tag" 1
  mtp_create_release_tag

}

function mtp_push_code() {

  out_warning "Pushing code to acquia" 1

  out_info "Pushing release to production: ${_MTP_RELEASE_PLATFORM}"
  mtp_push_release

  out_info "Pushing tag to production: ${_MTP_RELEASE_TAG}" 1
  mtp_push_tag

}

function mtp_active_code() {

  out_warning "Activing code to acquia" 1

  acquia_code_deploy ${_MTP_SUBSCRIPTION} ${_MTP_ENVIRONMENT_PROD} ${_MTP_RELEASE_TAG} && true
  if [ $? -ge 1 ]; then

    out_danger "An error during the push occurs, please check your connection"

  fi

  out_success "Tag ${_MTP_RELEASE_TAG} activate in production"

}

function mtp_clear_caches() {

  if [[ ${_MTP_CLEAR_CACHE} == "true" ]]; then

    out_warning "Clearing caches" 1

    mtp_all_caches
    mtp_clear_varnish

  fi

}

function mtp_rebase_master() {

  out_warning "Syncing master with the last release ${_MTP_ACQUIA_SUBSCRIPTION_PATH}" 1
  git_checkout ${_MTP_ACQUIA_REPO_MASTER_RESOURCE} ${_MTP_ACQUIA_SUBSCRIPTION_PATH}
  git_rebase ${_MTP_ACQUIA_SUBSCRIPTION_PATH} ${_MTP_RELEASE_TAG}
  if [ $? -eq 0 ]; then

    out_success "Master rebased successfully"

    out_info "Pushing master branch" 1
    git_push_in_branch ${_MTP_ACQUIA_SUBSCRIPTION_PATH} ${_MTP_ACQUIA_REPO_MASTER_RESOURCE} && true
    if [ $? -ge 1 ]; then

      mtp_abort "PushError" "An error during the push occurs, please check your connection"

    fi

    out_success "Master pushed successfully"

  else

    mtp_abort "RebaseError" "Problems to rebase master, aborting"

  fi

}

function mtp_post_execution() {

  # TODO Generate MTP report

  out_notify "MTP finished" "MTP finished for [ ${_MTP_TICKET_ID} ] at [ ${_MTP_SUBSCRIPTION} ]"

}
