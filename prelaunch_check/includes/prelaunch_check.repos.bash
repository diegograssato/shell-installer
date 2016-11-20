#!/usr/bin/env bash

function prelaunch_check_load_vendor_repository() {

  out_info "Fetching repository URL for ${_PRELAUNCH_CHECK_SUBSCRIPTION}" 1
  local _PRELAUNCH_CHECK_REPO_URL=$(acquia_get_repository_url ${_PRELAUNCH_CHECK_SUBSCRIPTION} ${_PRELAUNCH_CHECK_DEFAULT_ENVIRONMENT})
  out_check_status $? "Repository URL found: ${_PRELAUNCH_CHECK_REPO_URL}" "Error while getting repository URL"

  if [[ ! "${_PRELAUNCH_CHECK_REPO_URL}" == *"${_PRELAUNCH_CHECK_SUBSCRIPTION}.git"* ]]; then

    raise AcquiaAPI "[prelaunch_check_load_repository] Not a valid git url was returned from API"

  fi

  out_info "Fetching active resource in @${_PRELAUNCH_CHECK_SUBSCRIPTION}.${_PRELAUNCH_CHECK_DEFAULT_ENVIRONMENT}" 1
  local _PRELAUNCH_CHECK_REPO_RESOURCE=$(acquia_get_repository_active_resource ${_PRELAUNCH_CHECK_SUBSCRIPTION} ${_PRELAUNCH_CHECK_DEFAULT_ENVIRONMENT})
  out_check_status $? "GIT resource found: ${_PRELAUNCH_CHECK_REPO_RESOURCE}" "Error while getting GIT resource"

  git_load_repositories ${_PRELAUNCH_CHECK_REPO_URL} ${_PRELAUNCH_CHECK_REPO_RESOURCE} ${_PRELAUNCH_CHECK_REPO_PATH}

}

function prelaunch_check_load_platform_repository() {

  local _PRELAUNCH_CHECK_PLAT_VERSION=$(os_utils_get_platform_version "${_PRELAUNCH_CHECK_WORKSPACE}/${_PRELAUNCH_CHECK_SUBSCRIPTION}")
  out_info "Platform version found: ${_PRELAUNCH_CHECK_PLAT_VERSION}" 1

  local _PRELAUNCH_CHECK_PLAT_VERSION_BRANCH=$(prelaunch_check_get_plat_branch_from_version ${_PRELAUNCH_CHECK_PLAT_VERSION})
  [ -z "${_PRELAUNCH_CHECK_PLAT_VERSION_BRANCH}" ] && raise RequiredParameterNotFound "Could not find a ${_PRELAUNCH_CHECK_PLAT_VERSION} branch, please check prelaunch_check_conf.bash"
  out_info "Will diff against platform version branch: ${_PRELAUNCH_CHECK_PLAT_VERSION_BRANCH}"

  os_utils_checkout_platform_repo ${_PRELAUNCH_CHECK_PLAT_VERSION_BRANCH}

}
