#!/usr/bin/env bash

function git_clone_only() {

  local _GIT_CLONE_REPO_URL=${1:-}
  local _GIT_REPO_PATH=${2:-}

  if [ -z "${_GIT_CLONE_REPO_URL}" ]; then

    raise RequiredParameterNotFound "[git_clone_only] Please provide a valid repository"

  fi

  out_info "Cloning repository: [ ${_GIT_CLONE_REPO_URL} ]." 1
  ${_GIT} clone ${_GIT_CLONE_REPO_URL} ${_GIT_REPO_PATH}
  out_check_status $? "Cloned with success" "Clone failed"

}

function check_is_same_repostory() {

  local _GIT_CLONE_REPO_URL=${1:-}
  local _GIT_REPO_PATH=${2:-}

  if [ -z "${_GIT_CLONE_REPO_URL}" ]; then

    raise RequiredParameterNotFound "[check_is_same_repostory] Please provide a valid repository"

  fi

  local _GIT_ACTIVE_REPOSITORY=$(${_GIT} -C ${_GIT_REPO_PATH} config --get remote.origin.url)
  if [ "${_GIT_CLONE_REPO_URL}" == "${_GIT_ACTIVE_REPOSITORY}" ]; then

    return 0;

  fi

  return 1;

}

function git_check_if_resource_exists() {

  local _GIT_RESOURCE=${1:-}
  local _GIT_REPO_PATH=${2:-}
  local _GIT_REMOTES=$(git -C ${_GIT_REPO_PATH} remote)
  local _GIT_REMOTE_LIST=""

  for _FORMAT in ${_GIT_REMOTES}; do

    _GIT_REMOTE_LIST="${_GIT_REMOTE_LIST} ${_FORMAT}"

  done

  _GIT_REMOTE_LIST=$(echo ${_GIT_REMOTE_LIST} | sed "s/ /\|/g")

  if (${_GIT} -C ${_GIT_REPO_PATH} tag -l | egrep -q "^\s*((${_GIT_REMOTE_LIST})?/)?${_GIT_RESOURCE}$"); then

    out_success "Tag found"
    return 0

  elif (${_GIT} -C ${_GIT_REPO_PATH} branch -a | egrep -q "^\s*(remotes/)?((${_GIT_REMOTE_LIST})?/)?${_GIT_RESOURCE}$"); then

    out_success "Branch found"
    return 0

  elif (${_GIT} -C ${_GIT_REPO_PATH} cat-file -e ${_GIT_RESOURCE}); then

    out_success "Commit found"
    return 0

  else

    out_warning "No resource found for ${_GIT_RESOURCE}"
    return 1

  fi

}

function git_extract_repository_name() {

  local _GIT_REPO=${1:-}

  if [ ! -z ${_GIT_REPO} ]; then

    local _REPO_BASENAME=$(basename "${_GIT_REPO}" ".${_GIT_REPO##*.}")
    echo ${_REPO_BASENAME}

  else

    raise RepositoryNotFound "[git_extract_repository_name] ${_GIT_REPO} is not a valid repository"

  fi

}

function git_is_tag() {

  local _GIT_REPO_PATH=${1:-}
  local _GIT_RESOURCE=${2:-}

  if [ ! -d ${_GIT_REPO_PATH} ]; then

    raise FolderNotFound "[git_is_tag] ${_GIT_REPO_PATH} is not a valid folder"

  fi

  if ${_GIT} -C ${_GIT_REPO_PATH} show-ref --tags | ${_GREP} -q  ${_GIT_RESOURCE}; then

    return 0

  fi

  return 1

}
