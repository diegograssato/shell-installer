#!/usr/bin/env bash

function docker_compose_restart() {

  local _DOCKER_COMPOSE_FILE=${1:-}
  if [ ! -f "${_DOCKER_COMPOSE_FILE}" ]; then

    raise FileNotFound "[docker_compose_restart] Can't find a suitable configuration file in this directory: ${_SF_SCRIPTS_CONFIG}. \n\tAre you in the right directory? \n\tSupported filenames: docker-compose.yml, docker-compose.yaml\n"

  fi

  ${_DOCKER_COMPOSE} -f ${_DOCKER_COMPOSE_FILE} restart

}

function docker_compose_up() {

  local _DOCKER_COMPOSE_FILE=${1:-}
  local _DOCKER_CONTAINER=${2:-}

  if [ ! -f "${_DOCKER_COMPOSE_FILE}" ]; then

    raise FileNotFound "[docker_compose_restart] Can't find a suitable configuration file in this directory: ${_SF_SCRIPTS_CONFIG}. \n\tAre you in the right directory? \n\tSupported filenames: docker-compose.yml, docker-compose.yaml\n"

  fi

  ${_DOCKER_COMPOSE} -f ${_DOCKER_COMPOSE_FILE} up -d ${_DOCKER_CONTAINER}

}

function docker_container_exists() {

  if [ -z ${1:-} ]; then

    raise RequiredParameterNotFound "[docker_inspect] Please provide a container to be inspected"

  else

    local _DOCKER_CONTAINER=${1}

  fi

  local _DOCKER_CONTAINER_IS_UP=$(${_DOCKER} ps -a --filter "name=${_DOCKER_CONTAINER}$" --format "{{.Names}}")

  if [ "${_DOCKER_CONTAINER_IS_UP}" != "${_DOCKER_CONTAINER}" ]; then

    return 1

  fi

  return 0

}

function docker_container_is_running() {

  if [ -z ${1:-} ]; then

    raise RequiredParameterNotFound "[docker_inspect] Please provide a container to be inspected"

  else

    local _DOCKER_CONTAINER=${1}

  fi

  local _DOCKER_CONTAINER_IS_RUNNING=$(${_DOCKER} inspect --format="{{ .State.Running }}" ${_DOCKER_CONTAINER})
  if [ "${_DOCKER_CONTAINER_IS_RUNNING}" == "false" ]; then

    return 1

  fi

  return 0

}


function docker_image_exists() {

  if [ -z ${1:-} ]; then

    raise RequiredParameterNotFound "[docker_image_exists] Please provide a image to be inspected"

  else

    local _DOCKER_IMAGE=${1}

  fi

  local _DOCKER_CONTAINER_EXISTS=$(${_DOCKER} inspect --format="{{ .Id }}" --type=image ${_DOCKER_IMAGE})
  if [ -z "${_DOCKER_CONTAINER_EXISTS}" ]; then

    return 0

  fi

  return 1

}

function docker_list_ports() {

  ${_DOCKER} ps --filter "name=os_" --filter status=running --format "{{.Names}} {{.Ports}}" | sed "s/0\.0\.0\.0://g" | sed "s#/tcp##g"

}

function docker_list_local() {

  ${_DOCKER} ps -a
  ${_DOCKER} ps --filter "name=os_" --format "{{.ID}} {{.Names}}"

}

function docker_image_pull() {

  if [ -z ${1:-} ]; then

    raise RequiredParameterNotFound "[docker_image_pull] Please provide a image to pull"

  else

    local _DOCKER_IMAGE=${1}

  fi

  ${_DOCKER} pull ${_DOCKER_IMAGE}

}

function docker_exec() {

  if [ -z ${1:-} ]; then

    raise RequiredParameterNotFound "[docker_exec] Please provide a container to be exec"

  else

    local _DOCKER_CONTAINER=${1}

  fi

  if [ -z ${2:-} ] || [ ${2:-} == "false" ]; then

    local _DOCKER_INTERACTIVE="-t"

  elif [ ${2:-} == "true" ]; then

    local _DOCKER_INTERACTIVE="-it"

  fi

  shift 2
  local _SHELL='bash -c '
  local _DOCKER_ARGUMENTS="${@}"
  readonly _DOCKER_ARGUMENTS=$(escape_arg "$_DOCKER_ARGUMENTS")

  echo ${_DOCKER} exec -u docker ${_DOCKER_INTERACTIVE} ${_DOCKER_CONTAINER} ${_SHELL}  "$_DOCKER_ARGUMENTS"
  ${_DOCKER} exec -u docker ${_DOCKER_INTERACTIVE} ${_DOCKER_CONTAINER} ${_SHELL}  "$_DOCKER_ARGUMENTS"

}

function docker_stop() {

  if [ -z ${1:-} ]; then

    raise RequiredParameterNotFound "[docker_stop] Please provide a container to be exec"

  else

    local _DOCKER_CONTAINER=${1}

  fi

  shift 1
  local _DOCKER_ARGS="${@}"

  ${_DOCKER} stop ${_DOCKER_CONTAINER} "${_DOCKER_ARGS}" > /dev/null 2>&1

}

function docker_rm() {

  if [ -z ${1:-} ]; then

    raise RequiredParameterNotFound "[docker_stop] Please provide a container to be exec"

  else

    local _DOCKER_CONTAINER=${1}

  fi

  ${_DOCKER} rm ${_DOCKER_CONTAINER} > /dev/null 2>&1

}

function docker_run() {

  local _DOCKER_ARGS="${@}"

  ${_DOCKER} run ${_DOCKER_ARGS}

}


function docker_get_ip() {

  if [ -z ${1:-} ]; then

    raise RequiredParameterNotFound "[docker_get_ip] Please provide a container to be exec"

  else

    local _DOCKER_CONTAINER=${1}

  fi

  local _IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${_DOCKER_CONTAINER})

  echo ${_IP}


}
