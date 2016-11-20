#!/usr/bin/env bash

################################################################################
# @param String _GIT_REPO_URL - URL of GIT repository
# @param String _GIT_REPO_RESOURCE - Branch/Tag to be checked out
# @param String _GIT_REPO_PATH - path to destination folder of the clone
#
# Will clone, reset, clean, checkout and update target repository. High level
# function to make sure that exactly the latest version of a GIT repository is
# loaded.
################################################################################
function git_load_repositories() {

  local _GIT_REPO_URL=${1:-}
  local _GIT_REPO_RESOURCE=${2:-}
  local _GIT_REPO_PATH=${3:-}
  local _GIT_REPO_PARENT_PATH="$(dirname ${_GIT_REPO_PATH})"

  filesystem_create_folder ${_GIT_REPO_PARENT_PATH}

  out_warning "Loading repository [ ${_GIT_REPO_URL} ]" 1
  git_clone ${_GIT_REPO_URL} ${_GIT_REPO_PATH}
  git_reset_repository ${_GIT_REPO_PATH}
  git_clean_repository ${_GIT_REPO_PATH}
  git_checkout ${_GIT_REPO_RESOURCE} ${_GIT_REPO_PATH}
  git_update ${_GIT_REPO_PATH}

}

################################################################################
# @param String _GIT_REPO_URL - URL of GIT repository
# @param String _GIT_REPO_PATH - path to destination folder of the clone
#
# Checkout a GIT repository URL in target folder. If the folder is already
# cloned it will check if the repo URL is the same and replace if changed.
################################################################################
function git_clone() {

  local _GIT_REPO_URL=${1:-}
  local _GIT_REPO_PATH=${2:-}

  if [ -z "${_GIT_REPO_URL}" ]; then

     raise RequiredParameterNotFound "[git_clone_only] Please provide a valid repository"

  fi

  out_info "Cloning repository ${_GIT_REPO_URL}"
  if [ ! -d ${_GIT_REPO_PATH} ]; then

    git_clone_only $@

  else

    # Fix folder is not git repository
    if [ ! -d "${_GIT_REPO_PATH}/.git" ]; then

      out_danger "Repo path found in ${_GIT_REPO_PATH} but missing .git. Reclonning repository"
      ${_RMF} ${_GIT_REPO_PATH}
      git_clone_only $@

    else

      if (! check_is_same_repostory $@); then

        out_danger "Swich of the repository detected, removing old repository folder"
        ${_RMF} ${_GIT_REPO_PATH}
        git_clone_only $@

      else

        out_success "Repository already cloned"

      fi

    fi

  fi

}

################################################################################
# @param String _GIT_REPO_PATH - path to GIT repository
#
# Updates the target repository if a branch is checked out by "git pull"
################################################################################
function git_update() {

  local _GIT_REPO_PATH=${1:-}

  if [ ! -d ${_GIT_REPO_PATH} ]; then

    raise FolderNotFound "[git_update] ${_GIT_REPO_PATH} folder does not exist"

  fi

  out_info "Updating repository: [ ${_GIT_REPO_PATH} ]" 1

  if ( ! git_is_current_resource_a_tag ${_GIT_REPO_PATH}); then

    ${_GIT} -C ${_GIT_REPO_PATH} pull
    out_check_status $? "Updated with success" "Update failed at ${_GIT_REPO_PATH}"

  fi

}

################################################################################
# @param String _GIT_REPO_RESOURCE - Branch/Tag to be checked out
# @param String _GIT_REPO_PATH - path to destination folder of the repo
#
# Checks out a given resource in the target repository. Will "git fetch --tags"
# before checking out the resource
################################################################################
function git_checkout() {

  local _GIT_REPO_RESOURCE=${1:-}

  if [ -z ${2:-} ] && [ ! -d ${2:-} ]; then

    raise RequiredParameterNotFound "[git_checkout] Please provida a valid repository path"

  else

    local _GIT_REPO_PATH=${2:-}

  fi

  out_info "Checking out resource: [ ${_GIT_REPO_RESOURCE} ]" 1

  ${_GIT} -C ${_GIT_REPO_PATH} fetch --tags

  (git_check_if_resource_exists ${_GIT_REPO_RESOURCE} ${_GIT_REPO_PATH}) && true
  local _GIT_FOUND_RESOURCE=$?

  if [ ${_GIT_FOUND_RESOURCE} -eq 1 ]; then

    raise RequiredParameterNotFound "[git_checkout] Resource ${_GIT_REPO_RESOURCE} not found in ${_GIT_REPO_PATH}"

  fi

  ${_GIT} -C ${_GIT_REPO_PATH} checkout ${_GIT_REPO_RESOURCE}
  out_check_status $? "Checkout with success" "Checkout failed at ${_GIT_REPO_RESOURCE}"

}

################################################################################
# @param String _GIT_REPO_PATH - path to destination folder of the repo
# @param String _GIT_BRANCH - branch name that will be created
#
# Creates a branch from the current position in the git repository
################################################################################
function git_checkout_new_branch() {

  local _GIT_REPO_PATH=${1:-}
  local _GIT_BRANCH=${2:-}

  if [ ! -d "${_GIT_REPO_PATH}" ]; then

     raise FolderNotFound "[git_checkout_new_branch] ${_GIT_REPO_PATH} is not a valid folder"

  fi

  if [ -z ${_GIT_BRANCH} ]; then

    raise RequiredParameterNotFound "[git_checkout_new_branch] Please provide a valid Branch name"

  fi

  ${_GIT} -C ${_GIT_REPO_PATH} checkout -b ${_GIT_BRANCH}

}

################################################################################
# @param String _GIT_REPO_PATH - path to destination folder of the repo
#
# Will "git reset --hard" if resource is a Tag
# Will "git reset --hard origin/" if resource is a Branch
################################################################################
function git_reset_repository() {

  if [ -z ${1:-} ] && [ ! -d ${1:-} ]; then

    raise RequiredParameterNotFound "[git_reset_repository] Please provida a valid repository path"

  else

    local _GIT_REPO_PATH=${1:-}

  fi

  out_info "Reseting repository [ ${_GIT_REPO_PATH} ]" 1
  local _GIT_ACTIVE_RESOURCE="$(${_GIT} -C ${_GIT_REPO_PATH} symbolic-ref -q --short HEAD || ${_GIT} -C ${_GIT_REPO_PATH} describe --tags --exact-match)"
  if [ ! -z ${_GIT_ACTIVE_RESOURCE} ]; then

    if ${_GIT} -C ${_GIT_REPO_PATH} show-ref --tags | ${_GREP} -q  ${_GIT_ACTIVE_RESOURCE}; then

      ${_GIT} -C ${_GIT_REPO_PATH} reset --hard ${_GIT_ACTIVE_RESOURCE}
      out_check_status $? "Reseting tag with success" "Fail on reset tag ${_GIT_ACTIVE_RESOURCE}"

    else

      ${_GIT} -C ${_GIT_REPO_PATH} reset --hard origin/${_GIT_ACTIVE_RESOURCE}
      out_check_status $? "Reseting origin/${_GIT_ACTIVE_RESOURCE} with success" "Fail on reset repository ${_GIT_ACTIVE_RESOURCE}"

    fi

  else

    ${_GIT} -C ${_GIT_REPO_PATH} reset --hard HEAD
    out_check_status $? "Reseting with success" "Fail on reset repository ${_GIT_ACTIVE_RESOURCE}"

  fi

}

################################################################################
# @param String _GIT_REPO_PATH - path to destination folder of the repo
#
# Will remove all untracked files and directories with "git clean -fd"
################################################################################
function git_clean_repository() {


  if [ -z ${1:-} ] && [ ! -d ${1:-} ]; then

    raise RequiredParameterNotFound "[git_clean_repository] Please provida a valid repository path"

  else

    local _GIT_REPO_PATH=${1:-}

  fi

  out_info "Clean repository [ ${_GIT_REPO_PATH} ]" 1
  ${_GIT} -C ${_GIT_REPO_PATH} clean -fd
  out_check_status $? "Repository cleared with success" "Fail on clean repository on ${_GIT_REPO_PATH}"

}

################################################################################
# @param String _GIT_REPO_RESOURCE - Branch/Tag to be checked out
# @param String _GIT_REPO_PATH - path to destination folder of the clone
# @param String _GIT_FILTER - URL of GIT repository
#
# Return all commit hashes which matched the given filter in the target resource
################################################################################
function git_list_commits_by_filter() {

	local _GIT_REPO_RESOURCE=${1:-}
  local _GIT_REPO_PATH=${2:-}
  local _GIT_FILTER=${3:-}

  if [ -z "${_GIT_REPO_RESOURCE}" ]; then

     raise RequiredParameterNotFound "[git_list_commits_by_filter] Please provide a valid branch/tag"

  fi

  if [ ! -d ${_GIT_REPO_PATH} ]; then

    raise FolderNotFound "[git_list_commits_by_filter] ${_GIT_REPO_PATH} is not a valid folder"

  fi

  if [ -z "${_GIT_FILTER}" ]; then

     raise RequiredParameterNotFound "[git_list_commits_by_filter] Please provide a valid Jira ID"

  fi

	local _GIT_COMMITS_HASH=$(${_GIT} -C ${_GIT_REPO_PATH} log ${_GIT_REPO_RESOURCE} --no-merges --pretty=tformat:"%h@%s" | egrep -w "${_GIT_FILTER}" | cut -d'@' -f1| tac)
	echo ${_GIT_COMMITS_HASH}

}

################################################################################
# @param String _GIT_REPO_PATH - path to destination folder of the clone
# @param String _GIT_COMMIT - commit to create the patch
# @param String _GIT_PATCH_FOLDER - destination folder to store the patch
#
# Creates a commit patch with "git format-patch" and stores at given location.
################################################################################
function git_create_patch() {

  local _GIT_REPO_PATH=${1:-}
  local _GIT_COMMIT=${2:-}
  local _GIT_PATCH_FOLDER=${3:-}

  if [ ! -d ${_GIT_REPO_PATH} ]; then

     raise RequiredParameterNotFound "[git_create_patch] Please provide a valid repository path"

  fi

  if [ -z "${_GIT_COMMIT}" ]; then

     raise RequiredParameterNotFound "[git_create_patch] Please provide a valid commit hash"

  fi

  if [ ! -d ${_GIT_PATCH_FOLDER} ]; then

     raise RequiredParameterNotFound "[git_create_patch] Please provide a valid folder"

  fi

  local _GIT_PATCH_FILE="${_GIT_PATCH_FOLDER}/${_GIT_COMMIT}.patch"
  local _GIT_PATCH_NAME=$(${_GIT} -C ${_GIT_REPO_PATH} format-patch -k --full-index --binary ${_GIT_COMMIT}^..${_GIT_COMMIT})

  ${_MV} "${_GIT_REPO_PATH}/${_GIT_PATCH_NAME}" ${_GIT_PATCH_FILE}

  out_success "Patch created: ${_GIT_PATCH_FILE}"

}

################################################################################
# @param String _GIT_REPO_PATH - path to destination folder of the clone
# @param String _GIT_COMMIT - commit to create the patch
# @param String _GIT_PATCH_FOLDER - destination folder to store the patch
#
# Applies the given commit patch from the given location into the given path
################################################################################
function git_am() {

  local _GIT_REPO_PATH=${1:-}
  local _GIT_COMMIT=${2:-}
  local _GIT_PATCH_FOLDER=${3:-}

  if [ ! -d ${_GIT_REPO_PATH} ]; then

     raise RequiredParameterNotFound "[git_am] Please provide a valid repository path"

  fi

  if [ -z "${_GIT_COMMIT}" ]; then

     raise RequiredParameterNotFound "[git_am] Please provide a valid commit hash"

  fi

  if [ ! -d ${_GIT_PATCH_FOLDER} ]; then

     raise RequiredParameterNotFound "[git_am] Please provide a valid folder"

  fi

  local _GIT_PATCH_FILE="${_GIT_PATCH_FOLDER}/${_GIT_COMMIT}.patch"

  out_info "Applying patch ${_GIT_PATCH_FILE} into [${_GIT_REPO_PATH}] - git am" 1

  ${_GIT} -C ${_GIT_REPO_PATH} am -k "${_GIT_PATCH_FILE}"

}

################################################################################
# @param String _GIT_REPO_PATH - path to destination folder of the clone
# @param String _GIT_COMMIT - commit to create the patch
# @param String _GIT_PATCH_FOLDER - destination folder to store the patch
#
# Applies the given commit patch from the given location into the given path
################################################################################
function git_apply_patch() {

  local _GIT_REPO_PATH=${1:-}
  local _GIT_COMMIT=${2:-}
  local _GIT_PATCH_FOLDER=${3:-}

  if [ ! -d ${_GIT_REPO_PATH} ]; then

     raise RequiredParameterNotFound "[git_apply_patch] Please provide a valid repository path"

  fi

  if [ -z "${_GIT_COMMIT}" ]; then

     raise RequiredParameterNotFound "[git_apply_patch] Please provide a valid commit hash"

  fi

  if [ ! -d ${_GIT_PATCH_FOLDER} ]; then

     raise RequiredParameterNotFound "[git_apply_patch] Please provide a valid folder"

  fi

  local _GIT_PATCH_FILE="${_GIT_PATCH_FOLDER}/${_GIT_COMMIT}.patch"
  local _GIT_RUN_IN_REPO="${_GIT} -C ${_GIT_REPO_PATH}"

  out_info "Applying patch ${_GIT_PATCH_FILE} into [${_GIT_REPO_PATH}] - git apply" 1

  local _SUBJECT=$(cat ${_GIT_PATCH_FILE} | sed -n '/^Subject:/,/^---$/p' | sed -r "s/^Subject: |---//" | tr "\n" " ")
  local _AUTHOR=$(cat ${_GIT_PATCH_FILE} | grep -E "^From:" | sed "s/^From: //")

  ${_GIT_RUN_IN_REPO} apply ${_GIT_PATCH_FILE}
  # Abort if patch failed
  [ $? -ge 1 ] && return 1

  git_commit_all ${_GIT_REPO_PATH} "${_SUBJECT}" "${_AUTHOR}"

}

################################################################################
# @param String _GIT_REPO_PATH - path to destination folder of the clone
# @param String _GIT_SUBJECT - commit message
# @param OPTIONAL String _GIT_AUTHOR - commit message
#
# Applies all modifications and new files and performs a commit.
################################################################################
function git_commit_all() {

  local _GIT_REPO_PATH=${1:-}
  local _GIT_SUBJECT=${2:-}
  local _GIT_AUTHOR=${3:-}

  if [ ! -d ${_GIT_REPO_PATH} ]; then

     raise RequiredParameterNotFound "[git_commit_all] Please provide a valid repository path"

  fi

  if [ -z "${_GIT_SUBJECT}" ]; then

     raise RequiredParameterNotFound "[git_commit_all] Please provide a valid coment"

  fi

  local _GIT_RUN_IN_REPO="${_GIT} -C ${_GIT_REPO_PATH}"
  local _GIT_COMMIT_PARAM=""

  ${_GIT_RUN_IN_REPO} add -A

  if [ -n "${_GIT_AUTHOR}" ]; then

    _GIT_COMMIT_PARAM="--author=${_GIT_AUTHOR}"

  fi

  ${_GIT_RUN_IN_REPO} commit -m "${_GIT_SUBJECT}" "${_GIT_COMMIT_PARAM}"

}

################################################################################
# @param String _GIT_REPO_PATH - path to destination folder of the clone
# @param String _GIT_REPO_BRANCH - destination push branch
#
# Will push all commits in the current branch to the given remote branch.
################################################################################
function git_push_in_branch() {

  local _GIT_REPO_PATH=${1:-}
  local _GIT_REPO_BRANCH=${2:-}

  if [ ! -d ${_GIT_REPO_PATH} ]; then

     raise RequiredParameterNotFound "[git_push] Please provide a valid repository path"

  fi

  if [ -z ${_GIT_REPO_BRANCH} ]; then

     raise RequiredParameterNotFound "[git_push] Please provide a valid repository branch"

  fi

  local _GIT_RUN_IN_REPO="${_GIT} -C ${_GIT_REPO_PATH}"

  ${_GIT_RUN_IN_REPO} push -u origin ${_GIT_REPO_BRANCH}

}

################################################################################
# @param String _GIT_REPO_PATH - path to destination folder of the clone
#
# Aborts the current am session
################################################################################
function git_abort_am() {

  local _GIT_REPO_PATH=${1:-}

  if [ ! -d ${_GIT_REPO_PATH} ]; then

    raise RequiredParameterNotFound "[git_abort_am] Please provide a valid repository path"

  fi

  local _GIT_RUN_IN_REPO="${_GIT} -C ${_GIT_REPO_PATH}"

  out_warning "Aborting git am session" 1

  ${_GIT_RUN_IN_REPO} am --abort

}

################################################################################
# @param String _GIT_REPO_PATH - path to destination folder of the clone
#
# Checks if the current resource in a repository is a tag
################################################################################
function git_is_current_resource_a_tag() {

  local _GIT_REPO_PATH=${1:-}

  if [ ! -d ${_GIT_REPO_PATH} ]; then

    raise FolderNotFound "[git_is_current_resource_a_tag] ${_GIT_REPO_PATH} is not a valid folder"

  fi

  local _GIT_ACTIVE_RESOURCE="$(${_GIT} -C ${_GIT_REPO_PATH} symbolic-ref -q --short HEAD || ${_GIT} -C ${_GIT_REPO_PATH} describe --tags --exact-match)"

	if [ ! -z ${_GIT_ACTIVE_RESOURCE} ]; then

    if (git_is_tag ${_GIT_REPO_PATH} ${_GIT_ACTIVE_RESOURCE}); then

      return 0

    fi

  fi

  return 1

}

################################################################################
# @param String _GIT_REPO_PATH - path to destination folder of the clone
#
# Reset and Clean local repository to the last commit
################################################################################
function git_clean_to_head() {

  local _GIT_REPO_PATH=${1:-}

  if [ ! -d ${_GIT_REPO_PATH} ]; then

    raise FolderNotFound "[git_clean_to_head] ${_GIT_REPO_PATH} is not a valid folder"

  fi

  out_info "Reseting repository to the last commit." 1
  ${_GIT} -C ${_GIT_REPO_PATH} reset --hard HEAD
  git_clean_repository ${_GIT_REPO_PATH}

}

################################################################################
# @param String _GIT_REPO_PATH - path to destination folder of the clone
#
# Return default resource
################################################################################
function git_get_current_resource() {

  local _GIT_REPO_PATH=${1:-}

  if [ ! -d ${_GIT_REPO_PATH} ]; then

    raise FolderNotFound "[git_get_current_resource] ${_GIT_REPO_PATH} is not a valid folder"

  fi

  local _GIT_ACTIVE_RESOURCE="$(${_GIT} -C ${_GIT_REPO_PATH} symbolic-ref -q --short HEAD || ${_GIT} -C ${_GIT_REPO_PATH} describe --tags --exact-match)"
  if [ -z ${_GIT_ACTIVE_RESOURCE} ]; then

    raise FolderNotFound "[git_get_current_resource] ${_GIT_ACTIVE_RESOURCE} resource not found."

  fi

  echo "${_GIT_ACTIVE_RESOURCE}"

}

################################################################################
# @param String _GIT_REPO_PATH - path to destination folder of the create tag
#
# Create new tag, if tag exists generate incremental tag
################################################################################
function git_tag() {

  local _GIT_REPO_PATH=${1:-}
  local _GIT_TAG_RESOURCE=${2:-}

  if [ ! -d ${_GIT_REPO_PATH} ]; then

    raise RequiredParameterNotFound "[git_tag] Please provide a valid repository path"

  fi
  if (git_is_tag ${_GIT_REPO_PATH} ${_GIT_TAG_RESOURCE}); then

   raise TagFound "[git_tag] Tag exists ${_GIT_TAG_RESOURCE}."

  fi

  local _GIT_RUN_IN_REPO="${_GIT} -C ${_GIT_REPO_PATH}"
  ${_GIT_RUN_IN_REPO} tag ${_GIT_TAG_RESOURCE}

}

################################################################################
# @param String _GIT_REPO_PATH - path to destination folder of the create tag
# @param String _GIT_ACTIVE_RESOURCE - tag resource
#
# Generate new tag string by tag resource
################################################################################
function git_generate_new_tag_name() {

  local _GIT_REPO_PATH="${1}"
  local _GIT_ACTIVE_RESOURCE="${2}"
  local _GIT_TAG_EXISTS=$(${_GIT} -C ${_GIT_REPO_PATH} tag -l | ${_GREP} "${_GIT_ACTIVE_RESOURCE}" | wc -l)
  local _INCREMENT="$(echo ${_GIT_TAG_EXISTS} | sed -e "s/${_GIT_ACTIVE_RESOURCE}//g" | sed -e "s/\.//g")"
  local _GIT_ACTIVE_RESOURCE="${_GIT_ACTIVE_RESOURCE}.${_GIT_TAG_EXISTS}";

  echo ${_GIT_ACTIVE_RESOURCE};

}

################################################################################
# @param String _GIT_REPO_PATH - path to destination folder of the clone
# @param String _GIT_COMMIT - commit to create the patch
# @param String _GIT_PATCH_FOLDER - destination folder to store the patch
#
# Applies the given commit using cherry-pick
################################################################################
function git_cherry_pick() {

  local _GIT_REPO_PATH=${1:-}
  local _GIT_COMMIT=${2:-}
  if [ ! -d ${_GIT_REPO_PATH} ]; then

     raise RequiredParameterNotFound "[git_cherry_pick] Please provide a valid repository path"

  fi

  if [ -z "${_GIT_COMMIT}" ]; then

     raise RequiredParameterNotFound "[git_cherry_pick] Please provide a valid commit hash"

  fi
  out_info "Applying cherry-pick to commit ${_GIT_COMMIT}" 1
  local _GIT_RUN_IN_REPO="${_GIT} -C ${_GIT_REPO_PATH}"
  ${_GIT_RUN_IN_REPO} cherry-pick ${_GIT_COMMIT}

}

################################################################################
# @param String _GIT_REPO_PATH - path to destination folder of the clone
# @param String _GIT_COMMIT - commit to create the patch
# @param String _GIT_PATCH_FOLDER - destination folder to store the patch
#
# Applies the given commit using cherry-pick
################################################################################
function git_rebase() {

  local _GIT_REPO_PATH=${1:-}
  local _GIT_RESOURCE=${2:-}
  if [ ! -d ${_GIT_REPO_PATH} ]; then

     raise RequiredParameterNotFound "[git_rebase] Please provide a valid repository path"

  fi

  if [ -z "${_GIT_RESOURCE}" ]; then

     raise RequiredParameterNotFound "[git_rebase] Please provide a valid resource"

  fi
  local _GIT_RUN_IN_REPO="${_GIT} -C ${_GIT_REPO_PATH}"

  out_info "Making rebase to ${_GIT_RESOURCE}" 1
  if [[ -d "${_GIT_REPO_PATH}/.git/rebase-apply" ]]; then

    ${_GIT_RUN_IN_REPO} rebase --abort

  fi

  ${_GIT_RUN_IN_REPO} rebase ${_GIT_RESOURCE} && true
  if [[ ("$?" -ne "0") ]]; then

    out_danger "Rebase failed for $_GIT_RESOURCE, aborting the rebase proccess."
    ${_GIT_RUN_IN_REPO} rebase --abort

    return 1;

  fi

  return 0;


}
