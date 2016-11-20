#!/usr/bin/env bash


function mtp_load_acquia_repository () {

  local _MTP_ACQUIA_REPO=$(subscription_configuration_get_acquia_repo ${_MTP_SUBSCRIPTION})
  if [ -z ${_MTP_ACQUIA_REPO} ]; then

    raise MissingRequiredConfig "[mtp_load_acquia_repository] Acquia repository not found for subscription ${_MTP_SUBSCRIPTION}. Please check the configuration file subscription.yml"

  fi

  ## REMOVER
  local _MTP_BRANCH_ACTUAL=$(${_MTP_RUN_GIT_ACQUIA} symbolic-ref -q --short HEAD)
  if [[ ${_DEBUG}  == "true" ]] &&  [[ ! "${_MTP_BRANCH_ACTUAL}" == "${_MTP_ACQUIA_REPO_STAGE_RESOURCE}" ]]; then

    out_warning "Rollback stage branch in ${_MTP_ACQUIA_REPO_STAGE_RESOURCE}. ${_MTP_ACQUIA_SUBSCRIPTION_PATH}"
    git -C ${_MTP_ACQUIA_SUBSCRIPTION_PATH} reset --hard
    git_clean_repository ${_MTP_ACQUIA_SUBSCRIPTION_PATH}
    git_checkout ${_MTP_ACQUIA_REPO_STAGE_RESOURCE} ${_MTP_ACQUIA_SUBSCRIPTION_PATH}
    ${_MTP_RUN_GIT_ACQUIA} branch -D ${_MTP_BRANCH_ACTUAL} # remover

  fi
  ## REMOVER

  git_load_repositories ${_MTP_ACQUIA_REPO} ${_MTP_ACQUIA_REPO_STAGE_RESOURCE} ${_MTP_ACQUIA_SUBSCRIPTION_PATH}

}


function mtp_generate_release_name() {

  local _REGEX="${_MTP_SUBSCRIPTION}\-uat\-([0-9]+\.?)+$"
  local _MTP_STAGE_PLATFORM_VERSION=""

  if (echo ${_MTP_ACQUIA_REPO_STAGE_RESOURCE} | ${_GREP} -qE "${_REGEX}"); then

    local _MTP_STAGE_PLATFORM_VERSION=$(echo ${_MTP_ACQUIA_REPO_STAGE_RESOURCE} | ${_GREP} -Eo "([0-9]+\.?)+$")

    #Create new release plataform
    local _MTP_RELEASE_PLATFORM_TMP="${_MTP_DRUPAL_CORE_VERSION}-${_MTP_STAGE_PLATFORM_VERSION}"
    echo "release-${_MTP_RELEASE_PLATFORM_TMP}-$(date +%Y-%m-%d)"

  fi

}


function mtp_create_release_branch() {

  _MTP_RELEASE_PLATFORM=$(mtp_generate_release_name)
  if [[ -z ${_MTP_RELEASE_PLATFORM} ]] && [[ ${_MTP_INTERACTIVE} == "true" ]]; then

    out_danger "No match ${_MTP_ACQUIA_REPO_STAGE_RESOURCE}" 1
    out_danger "Stage branch is not following the standard naming (<subscription>-uat-<platform-version>)"
    out_warning "Please enter the platform version:"
    out_info "Examples: 2.0, 2.4, 2.10, etc"
    read _MTP_STAGE_PLATFORM_VERSION

    #Create new release platform
    local _MTP_RELEASE_PLATFORM_TMP="${_MTP_DRUPAL_CORE_VERSION}-${_MTP_STAGE_PLATFORM_VERSION}"
    _MTP_RELEASE_PLATFORM="release-${_MTP_RELEASE_PLATFORM_TMP}-$(date +%Y-%m-%d)"

  fi

  if [[ -z ${_MTP_RELEASE_PLATFORM} ]] && [[ ${_MTP_INTERACTIVE} == "false" ]]; then

    mtp_abort "DetectPlataformError" "An error during the detecting plataform version occurs."

  fi

  ${_MTP_RUN_GIT_ACQUIA} checkout ${_MTP_ACQUIA_REPO_PROD_RESOURCE}
  if (git_check_if_resource_exists ${_MTP_RELEASE_PLATFORM} ${_MTP_ACQUIA_SUBSCRIPTION_PATH}); then

    ${_MTP_RUN_GIT_ACQUIA} checkout ${_MTP_RELEASE_PLATFORM}

  else

    git_checkout_new_branch ${_MTP_ACQUIA_SUBSCRIPTION_PATH}  ${_MTP_RELEASE_PLATFORM}

  fi

}

function mtp_create_release_tag() {

  _MTP_RELEASE_TAG=$(printf ${_MTP_RELEASE_PLATFORM} | sed -e "s/release/build/g")
  if (git_check_if_resource_exists ${_MTP_RELEASE_TAG} ${_MTP_ACQUIA_SUBSCRIPTION_PATH}); then

    out_info "Tag ${_MTP_RELEASE_TAG} exists, creating new tag"
    _MTP_RELEASE_TAG=$(git_generate_new_tag_name ${_MTP_ACQUIA_SUBSCRIPTION_PATH} ${_MTP_RELEASE_TAG})

  fi

  out_info "Creating tag: ${_MTP_RELEASE_TAG}"
  git_tag ${_MTP_ACQUIA_SUBSCRIPTION_PATH} ${_MTP_RELEASE_TAG}
  if [ $? -ge 1 ]; then

    mtp_abort "CreateTagError" "An error during the creating tag occurs."

  fi

  out_success "Tag created successfully, ${_MTP_RELEASE_TAG}"

}

function mtp_push_release() {

  git_push_in_branch ${_MTP_ACQUIA_SUBSCRIPTION_PATH} ${_MTP_RELEASE_PLATFORM} && true
  if [ $? -ge 1 ]; then

    mtp_abort "PushError" "An error during the push occurs, please check your connection"

  fi

  out_success "${_MTP_RELEASE_PLATFORM} pushed successfully"

}

function mtp_push_tag() {

  git_push_in_branch ${_MTP_ACQUIA_SUBSCRIPTION_PATH} ${_MTP_RELEASE_TAG} && true
  if [ $? -ge 1 ]; then

    mtp_abort "PushError" "An error during the push occurs, please check your connection"

  fi

  out_success "${_MTP_RELEASE_TAG} pushed successfully"

}

function mtp_abort() {

  local _MTP_ABORT_TYPE=${1:-}
  local _MTP_ABORT_MESSAGE=${2:-}

  if [ ${_MTP_ABORT_TYPE} == "CherryPickError" ]; then

    git -C ${_MTP_ACQUIA_SUBSCRIPTION_PATH} cherry-pick --abort

  fi

  git_reset_repository ${_MTP_ACQUIA_SUBSCRIPTION_PATH}
  git_clean_repository ${_MTP_ACQUIA_SUBSCRIPTION_PATH}

  out_warning "Rollback stage branch in ${_MTP_ACQUIA_REPO_STAGE_RESOURCE}. ${_MTP_ACQUIA_SUBSCRIPTION_PATH}"
  git_checkout ${_MTP_ACQUIA_REPO_STAGE_RESOURCE} ${_MTP_ACQUIA_SUBSCRIPTION_PATH}
  local _MTP_BRANCH_ACTUAL=$(${_MTP_RUN_GIT_ACQUIA} symbolic-ref -q --short HEAD)

  if [[ ! "${_MTP_BRANCH_ACTUAL}" == "${_MTP_ACQUIA_REPO_STAGE_RESOURCE}" ]]; then

    ${_MTP_RUN_GIT_ACQUIA} branch -D ${_MTP_BRANCH_ACTUAL}

  fi

  raise ${_MTP_ABORT_TYPE} "[mtp_abort] ${_MTP_ABORT_MESSAGE}"

}
