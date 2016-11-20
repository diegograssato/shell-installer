#!/usr/bin/env bash

import docker

function os_grunt_run_task() {

  if [ -z ${1:-} ]; then

    raise RequiredParameterNotFound "[os_grunt_run_task] Please provide a valid site"
  else

    local _OS_GRUNT_PLATFORM_ACQUIA_BRANCH_OUT=${1:-}

  fi

  if [ -z ${2:-} ]; then

    raise RequiredParameterNotFound "[os_grunt_run_task] Please provide a valid site"

  else

    local _OS_GRUNT_SUBSITE_REAL_NAME=${2:-}

  fi

  if [ -z ${3:-} ]; then

    raise RequiredParameterNotFound "[os_grunt_run_task] Please provide a valid container"

  else

    local _OS_GRUNT_DOCKER_CONTAINER_CLI=${3:-}

  fi

  shift 3

  local _OS_GRUNT_PARAMETERS=${@}

  if (docker_container_exists ${_OS_GRUNT_DOCKER_CONTAINER_CLI}); then

    local _COMMAND="run_grunt.sh ${_OS_GRUNT_PLATFORM_ACQUIA_BRANCH_OUT} ${_OS_GRUNT_SUBSITE_REAL_NAME} ${_OS_GRUNT_PARAMETERS}"
    docker_exec ${_OS_GRUNT_DOCKER_CONTAINER_CLI} "${_COMMAND}"


  else

    raise ContainerNotFound "[os_grunt_run_task] Please provide a valid container: ${_OS_GRUNT_DOCKER_CONTAINER_CLI} "

  fi

}

function os_grunt_run_task_full_path() {

  if [ -z ${1:-} ]; then

    raise RequiredParameterNotFound "[os_grunt_run_task_full_path] Please provide a valid theme path"

  else

    local _OS_GRUNT_SITE_THEME_PATH=${1:-}

  fi

  if [ -z ${2:-} ]; then

    raise RequiredParameterNotFound "[os_grunt_run_task_full_path] Please provide a valid container"

  else

    local _OS_GRUNT_DOCKER_CONTAINER_CLI=${2:-}

  fi

  shift 2

  local _OS_GRUNT_PARAMETERS=${@}

  if (docker_container_exists ${_OS_GRUNT_DOCKER_CONTAINER_CLI}); then

    local _COMMAND="run_grunt_full_path.sh ${_OS_GRUNT_SITE_THEME_PATH} ${_OS_GRUNT_PARAMETERS}"
    docker_exec ${_OS_GRUNT_DOCKER_CONTAINER_CLI} "${_COMMAND}"

  else

    raise ContainerNotFound "[os_grunt_run_task_full_path] Please provide a valid container: ${_OS_GRUNT_DOCKER_CONTAINER_CLI} "

  fi

}
