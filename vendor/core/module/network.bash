#!/usr/bin/env bash

function get_ip_by_domain() {

  local _DOMAIN=${1:-}

  if [ -z ${_DOMAIN} ]; then

    raise RequiredParameterNotFound "[get_ip_by_domain] Please provide a valid domain"

  fi

  local _IP=$(dig @8.8.8.8 +short ${_DOMAIN} | head -1)

  echo "${_IP}"

}

function service_check_status() {

  local _HOST=${1}
  local _PORT=${2}

  if [ -z ${_HOST} ]; then

    raise RequiredParameterNotFound "[service_check_status] Please provide a valid host"

  fi

  if [ -z ${_PORT} ]; then

    raise RequiredParameterNotFound "[service_check_status] Please provide a valid port"

  fi

  if (nc -z ${_HOST} ${_PORT}  >/dev/null 2>&1 && true); then

    return 0

  fi

  return 1

}

function get_ip() {

  local _INTERFACE=${1:-}
  if [[ -z ${_INTERFACE} ]]; then

    _INTERFACE="(eno1|eno0|eth0|eth1|wlan0|en0|en1|en2|awdl0)"

  fi

  if (is_linux); then

    ip addr  | grep -E "${_INTERFACE}" |grep "inet" | awk -F" " '{print $2}' | sed -e 's/\/.*$//'

  else

    ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}'

  fi

}
