#!/usr/bin/env bash

import drush

function os_utils_get_platform_version() {

  if [ -z ${1:-} ]; then

    raise RequiredParameterNotFound "[os_utils_get_platform_version] Please provide a valid path to repository"

  elif [ ! -d ${1:-} ]; then

    raise InvalidFolder "[os_utils_get_platform_version] Please provide a valid path to repository"

  else

    local _OS_UTILS_PATH=${1}

  fi

  ${_CD} ${_OS_UTILS_PATH} &>/dev/null

  _PLATFORM_VERSION=$(${_GREP} -R JJBOS_VERSION docroot/profiles/jjbos/)

  ${_CD} - &>/dev/null

  echo ${_PLATFORM_VERSION} | grep -Eo "[0-9]\.x-[0-9\.]+"

}

function os_utils_checkout_platform_repo() {

  if [ -z ${1:-} ]; then

    raise RequiredParameterNotFound "[os_utils_checkout_platform_repo] Please provide a valid OS platform branch"

  else

    local _PRELAUNCH_CHECK_PLAT_VERSION_BRANCH=${1}

  fi

  if [ -z ${_OS_UTILS_PLATFORM_WORKSPACE} ]; then

    raise MissingRequiredConfig "Please configure global variable _OS_UTILS_PLATFORM_WORKSPACE in config/os_utils_config.bash"

  fi

  if [ -z ${_OS_UTILS_PLATFORM_REPO} ]; then

    raise MissingRequiredConfig "Please configure global variable _OS_UTILS_PLATFORM_REPO in config/os_utils_config.bash"

  fi

  git_load_repositories ${_OS_UTILS_PLATFORM_REPO} ${_PRELAUNCH_CHECK_PLAT_VERSION_BRANCH} ${_OS_UTILS_PLATFORM_WORKSPACE}

}
