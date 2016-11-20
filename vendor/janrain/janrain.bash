#!/usr/bin/env bash

function janrain_entity() {

  local _JANRAIN_CLIENT_ID=${1}
  local _JANRAIN_CLIENT_SECRET=${2}
  local _JANRAIN_CONTENT_TYPE=${3}
  local _JANRAIN_POST_DATA=${4}
  local _JANRAIN_ENDPOINT=${5}

  if [ -z ${_JANRAIN_CLIENT_ID:-} ] || [ -z ${_JANRAIN_CLIENT_SECRET:-} ]; then

    raise RequiredConfigNotFound "[janrain_entity] Please configure variables _JANRAIN_CLIENT_ID and _JANRAIN_CLIENT_SECRET in configuration file [config/janrain_config.bash]"

  fi

  if [ -z ${_JANRAIN_DOMAIN_URL:-} ]; then

    raise RequiredConfigNotFound "[janrain_entity] Please configure variable _JANRAIN_DOMAIN_URL in configuration file [config/janrain_config.bash]"

  fi

  ${_CURL} -g -s -X POST -u ${_JANRAIN_CLIENT_ID}:${_JANRAIN_CLIENT_SECRET} -H "Content-Type: ${_JANRAIN_CONTENT_TYPE}" "${_JANRAIN_DOMAIN_URL}/${_JANRAIN_ENDPOINT}?${_JANRAIN_POST_DATA}"
}
