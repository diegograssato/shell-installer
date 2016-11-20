#!/usr/bin/env bash

import docker

function os_command_run_task() {

  if [ -z ${1:-} ]; then

    raise RequiredParameterNotFound "[os_command_run_task] Please provide a valid container"

  else

    local _OS_COMMAND_CONTAINER_CLI=${1:-}

  fi

  if [ -z ${2:-} ]; then

    raise RequiredParameterNotFound "[os_command_run_task] Please provide a valid path to run command"

  else

    local _OS_COMMAND_PATH=${2:-}

  fi

  shift 2

  if [[ -z ${@} ]]; then

    raise RequiredParameterNotFound "[os_command_run_task] Please provide the commands to run"

  else

    local _OS_COMMANDS=${@}

  fi

  if (docker_container_exists ${_OS_COMMAND_CONTAINER_CLI}); then

    local _COMMAND="[ ! -d ${_OS_COMMAND_PATH} ] && echo 'Folder does not exist' && exit; ${_CD} ${_OS_COMMAND_PATH} && ${_OS_COMMANDS}"
    docker_exec ${_OS_COMMAND_CONTAINER_CLI} "source /usr/local/bin/env.sh; ${_COMMAND}"

  else

    raise ContainerNotFound "[os_command_run_task] The container does not exist, please check: ${_OS_COMMAND_CONTAINER_CLI}"

  fi

}
