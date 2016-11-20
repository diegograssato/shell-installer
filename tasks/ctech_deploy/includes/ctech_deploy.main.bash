#!/usr/bin/env bash

function ctech_deploy_load_configurations() {

  if [ -z ${1:-} ]; then

    raise RequiredParameterNotFound "[ctech_deploy_load_configurations] Please provide a valid subscription"

  else

    _CTECH_DEPLOY_SUBSCRIPTION=${1}

  fi

  if [ -z ${2:-} ]; then

    raise RequiredParameterNotFound "[ctech_deploy_load_configurations] Please provide a valid environment"

  else

    _CTECH_DEPLOY_ENVIRONMENT=${2}

  fi

  if [ -z ${3:-} ]; then

    raise RequiredParameterNotFound "[ctech_deploy_load_configurations] Please provide a valid subsite"

  else

    _CTECH_DEPLOY_SUBSITE=${3}

  fi

  if [ -z ${4:-} ]; then

    raise RequiredParameterNotFound "[ctech_deploy_load_configurations] Please provide a JIRA Ticket ID"

  else

    _CTECH_DEPLOY_TICKET_ID=${4}

  fi

  out_warning "Loading configurations" 1

  filesystem_create_folder ${_CTECH_DEPLOY_FORK_WORKSPACE}
  filesystem_create_folder ${_CTECH_DEPLOY_ACQUIA_WORKSPACE}

  local _CTECH_DEPLOY_YML_SUBSCRIPTION="${SF_SCRIPTS_HOME}/config/subscriptions.yml"
  local _CTECH_DEPLOY_YML_SUBSCRIPTION_FILE_SUBSITE="${SF_SCRIPTS_HOME}/config/${_CTECH_DEPLOY_SUBSCRIPTION:-}.yml"

  # Load Subscription YML
  if [ ! -f "${_CTECH_DEPLOY_YML_SUBSCRIPTION}" ]; then

    raise FileNotFound "[ctech_deploy_load_configurations] File ${_CTECH_DEPLOY_YML_SUBSCRIPTION} not found!"

  else

    yml_parse ${_CTECH_DEPLOY_YML_SUBSCRIPTION} "_"

  fi

  # Load Subsite YML
  if [ ! -f "${_CTECH_DEPLOY_YML_SUBSCRIPTION_FILE_SUBSITE}" ]; then

    raise FileNotFound "[ctech_deploy_load_configurations] Missing configuration file ${_CTECH_DEPLOY_YML_SUBSCRIPTION_FILE_SUBSITE}"

  else

    eval $(yml_loader ${_CTECH_DEPLOY_YML_SUBSCRIPTION_FILE_SUBSITE} "_")

  fi

  local _CTECH_DEPLOY_ALL_SITES=$(subscription_configuration_get_sites ${_CTECH_DEPLOY_SUBSCRIPTION})

  _CTECH_DEPLOY_SUBSITE_NAME=$(site_configuration_get_subsite_name ${_CTECH_DEPLOY_SUBSITE} ${_CTECH_DEPLOY_SUBSCRIPTION})

  # Validate if subsite exists
  if [ -z ${_CTECH_DEPLOY_SUBSITE_NAME} ]; then

    out_danger "Site '${_CTECH_DEPLOY_SUBSITE}' not exists, select one from the list:" 1

    for SITE in ${_CTECH_DEPLOY_ALL_SITES}; do

      echo -e "  ${BGREEN} ${SITE} ${COLOR_OFF}"

    done

    raise RequiredSiteNotFound "[ctech_deploy_load_configurations] Site '${_CTECH_DEPLOY_SUBSITE}' does not exist, please provid a valid site"

  elif (subscription_configuration_check_site_exists_in_sub ${_CTECH_DEPLOY_SUBSCRIPTION} ${_CTECH_DEPLOY_SUBSITE}); then

    raise MissingRequiredConfig "[ctech_deploy_load_configurations] Subsite not found in configuration file ${_CTECH_DEPLOY_YML_SUBSCRIPTION_FILE_SUBSITE}"

  fi

  _CTECH_DEPLOY_PLATFORM_REPO_RESOURCE=$(subscription_configuration_get_plat_repo_resource "${_CTECH_DEPLOY_SUBSCRIPTION}")

  if [ -z ${_CTECH_DEPLOY_PLATFORM_REPO_RESOURCE} ]; then

    raise MissingRequiredConfig "[ctech_deploy_load_configurations] Repository resource not found for subscription ${_CTECH_DEPLOY_SUBSCRIPTION}"

  fi

  _CTECH_DEPLOY_MASTER=$(site_configuration_get_master ${_CTECH_DEPLOY_SUBSITE} ${_CTECH_DEPLOY_SUBSCRIPTION})

  if [ -z ${_CTECH_DEPLOY_MASTER} ]; then

    raise MissingRequiredConfig "[ctech_deploy_load_repositories] ${_CTECH_DEPLOY_SUBSITE} master repository not found. Please check the file ${_CTECH_DEPLOY_SUBSCRIPTION}.yml"

  fi

  _CTECH_DEPLOY_SUBSITE_BRANCH=$(site_configuration_get_master_branch_by_env ${_CTECH_DEPLOY_MASTER} ${_CTECH_DEPLOY_SUBSCRIPTION} ${_CTECH_DEPLOY_ENVIRONMENT})

  if [ -z ${_CTECH_DEPLOY_SUBSITE_BRANCH} ]; then

    raise MissingRequiredConfig "[ctech_deploy_load_repositories] ${_CTECH_DEPLOY_SUBSITE} branch not found. Please check the file ${_CTECH_DEPLOY_SUBSCRIPTION}.yml"

  fi

  _CTECH_DEPLOY_SUBSITE_PATH="${_CTECH_DEPLOY_FORK_WORKSPACE}/${_CTECH_DEPLOY_MASTER}"
  _CTECH_DEPLOY_ACQUIA_SUBSCRIPTION_PATH="${_CTECH_DEPLOY_ACQUIA_WORKSPACE}/${_CTECH_DEPLOY_SUBSCRIPTION}"

  # TODO Remove GIT references from here into git module
  _CTECH_DEPLOY_RUN_GIT_ACQUIA="${_GIT} -C ${_CTECH_DEPLOY_ACQUIA_SUBSCRIPTION_PATH}"
  _CTECH_DEPLOY_RUN_GIT_SUBSITE="${_GIT} -C ${_CTECH_DEPLOY_SUBSITE_PATH}"

  out_info "Fetching active GIT resource in ${_CTECH_DEPLOY_SUBSCRIPTION}.${_CTECH_DEPLOY_ENVIRONMENT}" 1
  _CTECH_DEPLOY_ACQUIA_REPO_RESOURCE=$(acquia_get_repository_active_resource ${_CTECH_DEPLOY_SUBSCRIPTION} ${_CTECH_DEPLOY_ENVIRONMENT})
  out_check_status $? "GIT resource found: ${_CTECH_DEPLOY_ACQUIA_REPO_RESOURCE}" "Error while getting GIT resource"

  if [ -z ${_CTECH_DEPLOY_ACQUIA_REPO_RESOURCE} ]; then

    raise MissingRequiredConfig "[ctech_deploy_load_repositories] Acquia repository resource not found for subscription ${_CTECH_DEPLOY_SUBSCRIPTION}."

  fi

  _CTECH_DEPLOY_RESOURCE_NAME="${_CTECH_DEPLOY_SUBSCRIPTION}-${_CTECH_DEPLOY_ENVIRONMENT}-$(date +%s)"
  _CTECH_DEPLOY_BRANCH_NAME="release-${_CTECH_DEPLOY_RESOURCE_NAME}"
  _CTECH_DEPLOY_TAG_NAME="build-${_CTECH_DEPLOY_RESOURCE_NAME}"

  out_info "Master configuration found. Repository [${_CTECH_DEPLOY_MASTER}] resource [${_CTECH_DEPLOY_SUBSITE_BRANCH}]"

  slack_notify "CTECH deployment for ${_CTECH_DEPLOY_TICKET_ID} in ${_CTECH_DEPLOY_SUBSITE}@${_CTECH_DEPLOY_SUBSCRIPTION}.${_CTECH_DEPLOY_ENVIRONMENT}"

}

function ctech_deploy_load_repositories() {

  out_warning "Loading subsite repository" 1
  ctech_deploy_load_subsite_repository

  out_warning "Loading acquia repository" 1
  ctech_deploy_load_acquia_repository

}

function ctech_deploy_load_commits() {

  out_warning "Loading commits for ticket ${_CTECH_DEPLOY_TICKET_ID}" 1

  _CTECH_DEPLOY_GIT_COMMITS=$(git_list_commits_by_filter ${_CTECH_DEPLOY_SUBSITE_BRANCH} ${_CTECH_DEPLOY_SUBSITE_PATH} ${_CTECH_DEPLOY_TICKET_ID})

  if [[ -z ${_CTECH_DEPLOY_GIT_COMMITS} ]]; then

    raise InvalidParameter "[ctech_deploy_load_commits] There are no commits from this ticket ${_CTECH_DEPLOY_TICKET_ID}"

  fi

  ctech_deploy_list_commits

}

function ctech_deploy_generate_patches() {

  out_warning "Generating patches from commits in stash" 1
  out_info "Generating MTS Patches, will be stored temporarily at ${_CTECH_DEPLOY_TEMP_PATCH_FOLDER}" 1
  ctech_deploy_patches_create

}

function ctech_deploy_prepare_release_branch() {

  if (git_is_current_resource_a_tag ${_CTECH_DEPLOY_ACQUIA_SUBSCRIPTION_PATH}); then

    out_warning "Active resource is a Tag. Creating release branch" 1

    git_checkout_new_branch ${_CTECH_DEPLOY_ACQUIA_SUBSCRIPTION_PATH} ${_CTECH_DEPLOY_BRANCH_NAME}

  fi

}

function ctech_deploy_apply_commit_patches() {

  out_warning "Applying patches to acquia repository" 1
  ctech_deploy_patches_apply

}

function ctech_deploy_grunt_workflow() {

  out_warning "Running grunt on acquia repository" 1

  _CTECH_DEPLOY_AFFECTED_THEMES=$(ctech_deploy_get_affected_themes)

  if [[ ! -z "${_CTECH_DEPLOY_AFFECTED_THEMES}" ]]; then

    ctech_deploy_run_grunt "${_CTECH_DEPLOY_AFFECTED_THEMES}"

  else

    out_info "There is no affected themes to run grunt" 1

  fi

}

function ctech_deploy_code() {

  out_warning "Pushing code to acquia" 1

  # git_push_in_branch ${_CTECH_DEPLOY_ACQUIA_SUBSCRIPTION_PATH} ${_CTECH_DEPLOY_ACQUIA_REPO_RESOURCE} && true
  git_push_branch_and_tag ${_CTECH_DEPLOY_ACQUIA_SUBSCRIPTION_PATH} ${_CTECH_DEPLOY_TAG_NAME}

  if [ $? -ge 1 ]; then

    ctech_deploy_abort_script "PushError" "An error occurred during the git push"

  fi

  acquia_code_path_deploy ${_CTECH_DEPLOY_SUBSCRIPTION} ${_CTECH_DEPLOY_ENVIRONMENT} ${_CTECH_DEPLOY_TAG_NAME}

  slack_notify ":white_check_mark: CTECH deployment completed for ${_CTECH_DEPLOY_TICKET_ID}"

}
