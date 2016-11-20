#!/usr/bin/env bash

function mts_load_configurations() {

  if [ -z ${1:-} ]; then

    raise RequiredParameterNotFound "[mts_load_configurations] Please provide a valid subsite"

  else

    _MTS_SUBSITE=${1}

  fi

  if [ -z ${2:-} ]; then

    raise RequiredParameterNotFound "[mts_load_configurations] Please provide a JIRA Ticket ID"

  else

    _MTS_TICKET_ID=${2^^}

  fi

  if [ -z ${3:-} ]; then

    raise RequiredParameterNotFound "[mts_load_configurations] Please provide a valid subscription"

  else

    _MTS_SUBSCRIPTION=${3}

  fi

  if [ -z ${4:-} ]; then

    _MTS_INTERACTIVE=false

  else

    _MTS_INTERACTIVE=${4}

  fi

  out_warning "Loading configurations" 1

  filesystem_create_folder ${_MTS_WEB_WORKSPACE}
  filesystem_create_folder ${_MTS_ACQUIA_WORKSPACE}

  local _MTS_YML_SUBSCRIPTION="${SF_SCRIPTS_HOME}/config/subscriptions.yml"
  local _MTS_YML_SUBSCRIPTION_FILE_SUBSITE="${SF_SCRIPTS_HOME}/config/${_MTS_SUBSCRIPTION:-}.yml"

  # Load Subscription YML
  if [ ! -f "${_MTS_YML_SUBSCRIPTION}" ]; then

    raise FileNotFound "[mts_load_configurations] File ${_MTS_YML_SUBSCRIPTION} not found!"

  else

    yml_parse ${_MTS_YML_SUBSCRIPTION} "_"

  fi

  # Load Subsite YML
  if [ ! -f "${_MTS_YML_SUBSCRIPTION_FILE_SUBSITE}" ]; then

    raise FileNotFound "[mts_load_configurations] Missing configuration file ${_MTS_YML_SUBSCRIPTION_FILE_SUBSITE}"

  else

    eval $(yml_loader ${_MTS_YML_SUBSCRIPTION_FILE_SUBSITE} "_")

  fi

  local _MTS_ALL_SITES=$(subscription_configuration_get_sites ${_MTS_SUBSCRIPTION})

  _MTS_SUBSITE_NAME=$(site_configuration_get_subsite_name ${_MTS_SUBSITE} ${_MTS_SUBSCRIPTION})

  # Validate if subsite exists
  if [ -z ${_MTS_SUBSITE_NAME} ]; then

    out_danger "Site '${_MTS_SUBSITE}' not exists, select one from the list:" 1

    for SITE in ${_MTS_ALL_SITES}; do

      echo -e "  ${BGREEN} ${SITE} ${COLOR_OFF}"

    done

    raise RequiredSiteNotFound "[mts_load_configurations] Site '${_MTS_SUBSITE}' does not exist, please provid a valid site"

  elif (subscription_configuration_check_site_exists_in_sub ${_MTS_SUBSCRIPTION} ${_MTS_SUBSITE}); then

    raise MissingRequiredConfig "[mts_load_configurations] Subsite not found in configuration file ${_MTS_YML_SUBSCRIPTION_FILE_SUBSITE}"

  fi

  out_info "Getting platform repository resource from subscription ${_MTS_SUBSCRIPTION}" 1
  _MTS_PLATFORM_REPO_RESOURCE=$(subscription_configuration_get_plat_repo_resource "${_MTS_SUBSCRIPTION}")
  out_check_status $? "Platform repository resource: ${_MTS_PLATFORM_REPO_RESOURCE}" "Failed to get repository resource"

  if [ -z ${_MTS_PLATFORM_REPO_RESOURCE} ]; then

    raise MissingRequiredConfig "[mts_load_configurations] Repository resource not found for subscription ${_MTS_SUBSCRIPTION}"

  fi

  _MTS_SUBSITE_BRANCH=$(site_configuration_get_subsite_branch ${_MTS_SUBSITE} ${_MTS_SUBSCRIPTION})

  if [ -z ${_MTS_SUBSITE_BRANCH} ]; then

    raise MissingRequiredConfig "[mts_load_repositories] ${_MTS_SUBSITE} branch not found. Please check the file ${_MTS_SUBSCRIPTION}.yml"

  fi

  # Get paths
  _MTS_PLATFORM_SUBSITES_PATH="${_MTS_WEB_WORKSPACE}/${_MTS_PLATFORM_REPO_RESOURCE^^}/sites"
  _MTS_ACQUIA_SUBSCRIPTION_PATH="${_MTS_ACQUIA_WORKSPACE}/${_MTS_SUBSCRIPTION}"
  _MTS_SUBSITE_PATH="${_MTS_PLATFORM_SUBSITES_PATH}/${_MTS_SUBSITE}"

  _MTS_RUN_GIT_ACQUIA="${_GIT} -C ${_MTS_ACQUIA_SUBSCRIPTION_PATH}"
  _MTS_RUN_GIT_SUBSITE="${_GIT} -C ${_MTS_SUBSITE_PATH}"

  if [ "${_MTS_SUBSCRIPTION,,}" == "osops" ]; then

    _MTS_SUBSCRIPTION_ENVIRONMENT="dev"

  fi

  _MTS_ACQUIA_REPO_RESOURCE=$(acquia_get_repository_active_resource ${_MTS_SUBSCRIPTION} ${_MTS_SUBSCRIPTION_ENVIRONMENT})

  if [ -z ${_MTS_ACQUIA_REPO_RESOURCE} ]; then

    raise MissingRequiredConfig "[mts_load_repositories] Acquia repository resource not found for subscription ${_MTS_SUBSCRIPTION}."

  fi

  # if is jenkins change container name
  if [ ! -z ${JENKINS_HOME+x} ]; then

    _MTS_DOCKER_CONTAINER=${SF_SCRIPTS_CONTAINER_CLI_NAME}

  else

    slack_notify "MTS Site ${_MTS_SUBSITE} for ${_MTS_TICKET_ID} in ${_MTS_SUBSCRIPTION}"

  fi

}

function mts_metrics_init() {

  metrics_add ${_MTS_SUBSITE}
  metrics_add ${_MTS_TICKET_ID}
  metrics_add ${_MTS_SUBSCRIPTION}
  metrics_add ${_MTS_INTERACTIVE}

}

function mts_load_repositories() {

  out_warning "Loading subsite repository" 1
  mts_load_subsite_repository

  out_warning "Loading acquia repository" 1
  mts_load_acquia_repository

}

function mts_load_commits() {

  out_warning "Loading commits for ticket ${_MTS_TICKET_ID}" 1

  # If MTS is on interactive mode, skip duplicate deploy validation for manual skip
  if (! ${_MTS_INTERACTIVE}); then

    mts_validate_duplicate_deployment

  fi

  _MTS_GIT_COMMITS=$(git_list_commits_by_filter ${_MTS_SUBSITE_BRANCH} ${_MTS_SUBSITE_PATH} ${_MTS_TICKET_ID})

  if [[ -z ${_MTS_GIT_COMMITS} ]]; then

    raise InvalidParameter "[mts_load_commits] There are no commits from this ticket ${_MTS_TICKET_ID}"

  fi

  mts_list_commits

}

function mts_generate_patches() {

  out_warning "Generating patches from commits in stash" 1
  out_info "Generating MTS Patches, will be stored temporarily at ${_MTS_TEMP_PATCH_FOLDER}"
  mts_patches_create

}

function mts_apply_commit_patches() {

  out_warning "Applying patches to acquia repository" 1
  mts_patches_apply

}

function mts_grunt_workflow() {

  out_warning "Running grunt on acquia repository" 1

  local _MTS_AFFECTED_THEMES=$(mts_get_affected_themes)

  if [[ ! -z "${_MTS_AFFECTED_THEMES}" ]]; then

    mts_run_grunt "${_MTS_AFFECTED_THEMES}"

  else

    out_info "There is no affected themes to run grunt" 1

  fi

}

function mts_push_code() {

  out_warning "Pushing code to acquia" 1

  git_push_in_branch ${_MTS_ACQUIA_SUBSCRIPTION_PATH} ${_MTS_ACQUIA_REPO_RESOURCE} && true

  if [ $? -ge 1 ]; then

    mts_abort "PushError" "An error during the push occurs, please check your connection"

  fi

}

function mts_tracking_stash() {

  _TICKETS="$(echo ${_MTS_TICKET_ID}| tr "|" " ")"
  out_warning "Genereting tag to your MTS for the tickets ${_MTS_TICKET_ID}." 1
  for _TICKET in ${_TICKETS}; do

    if [[ -n ${_TICKET} ]]; then

      _MTS_GIT_COMMITS_BY_TICKET=$(git_list_commits_by_filter ${_MTS_SUBSITE_BRANCH} ${_MTS_SUBSITE_PATH} ${_TICKET})

      mts_create_tag_in_stash ${_TICKET} ${_MTS_GIT_COMMITS_BY_TICKET}

    fi
  done


}

function mts_create_tag_in_stash() {

  local _MTS_TICKET=${1}
  shift 1;
  local _MTS_COMMITS=${@}

  local _MTS_LAST_COMMIT=$(get_last_element "${_MTS_COMMITS}")
  if [[ -z ${_MTS_LAST_COMMIT} ]]; then

    raise InvalidParameter "[mts_create_tag_in_stash] There are no commits from this ticket ${_MTS_TICKET}."

  fi

  local _MTS_TAG_ID="${_MTS_TICKET}-MTS"
  if (git_is_tag ${_MTS_SUBSITE_PATH} ${_MTS_TAG_ID}); then

   out_warning "Tag exists [ ${_MTS_TAG_ID} ], genereting new tag." 1
   local _MTS_TAG_ID=$(git_generate_new_tag_name ${_MTS_SUBSITE_PATH} ${_MTS_TAG_ID})
   out_check_status $? "New tag is ${_MTS_TAG_ID}." "Error on genetate new tag."

  fi

  local _MTS_CURRENT_BRANCH=$(git_get_current_resource ${_MTS_SUBSITE_PATH})

  out_warning "Creating tag in the stash [ ${_MTS_TAG_ID} ]." 1
  git_checkout ${_MTS_LAST_COMMIT} ${_MTS_SUBSITE_PATH}
  git_tag ${_MTS_SUBSITE_PATH} ${_MTS_TAG_ID}
  out_check_status $? "Tag created successfully." "Error on create tag."

  out_warning "Pushing tag [ ${_MTS_TAG_ID} ] to stash." 1
  git_checkout ${_MTS_CURRENT_BRANCH} ${_MTS_SUBSITE_PATH}
  git_push_in_branch ${_MTS_SUBSITE_PATH} ${_MTS_TAG_ID}
  out_check_status $? "Tag pushed successfully." "Error on push tag."

}

function mts_clear_caches() {

  out_warning "Clearing all caches for ${_MTS_SUBSITE} in ${_MTS_SUBSCRIPTION}.${_MTS_SUBSCRIPTION_ENVIRONMENT}" 1

  acquia_clear_all_caches ${_MTS_SUBSCRIPTION} ${_MTS_SUBSCRIPTION_ENVIRONMENT} ${_MTS_SUBSITE}

}

function mts_post_execution() {

  # TODO Generate MTS report

  out_notify "MTS finished" "MTS finished for [ ${_MTS_TICKET_ID} ] in site [ ${_MTS_SUBSITE} ] at [ ${_MTS_SUBSCRIPTION} ]"

}
