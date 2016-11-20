#!/usr/bin/env bash

function cloudflare_domain_info() {


  if [ -z ${_CLOUDFLARE_CLIENT_EMAIL:-} ]; then

    raise RequiredConfigNotFound "[cloudflare_domain_info] Please configure variables _CLOUDFLARE_CLIENT_EMAIL in configuration file [config/cloudlare_config.bash]."

  fi

  if [ -z ${_CLOUDFLARE_TOKEN:-} ]; then

    raise RequiredConfigNotFound "[cloudflare_domain_info] Please configure variables _CLOUDFLARE_TOKEN in configuration file [config/cloudlare_config.bash]."

  fi

  if [ -z ${_CLOUDFLARE_ENDPOINT:-} ]; then

    raise RequiredConfigNotFound "[cloudflare_domain_info] Please configure variable _CLOUDFLARE_ENDPOINT in configuration file [config/cloudlare_config.bash]."

  fi

  local _CLOUDFLARE_DOMAIN=${1}
  if [ -z ${_CLOUDFLARE_DOMAIN:-} ]; then

    raise RequiredConfigNotFound "[cloudflare_domain_info] Please provaid a valid domain."

  else

    # Detect domains using protocol
    if (echo ${_CLOUDFLARE_DOMAIN} | egrep -q "^http[s]"); then

      _CLOUDFLARE_DOMAIN=$(echo ${_CLOUDFLARE_DOMAIN} | sed 's~http[s]*://~~g')

    fi

    # Detect domains using www
    if (echo ${_CLOUDFLARE_DOMAIN} | egrep -q "^www\."); then

      _CLOUDFLARE_DOMAIN=${_CLOUDFLARE_DOMAIN:4}

    fi

    # Detect edit domains
    if (echo ${_CLOUDFLARE_DOMAIN} | egrep -q "^edit\."); then

      _CLOUDFLARE_DOMAIN=${_CLOUDFLARE_DOMAIN:5}

    fi

  fi

  local _CLOUDFLARE_REQUEST_PARAM_ZONE="/zones?name=${_CLOUDFLARE_DOMAIN}"
  local _CLOUDFLARE_REQUEST_PARAM="&status=active&page=1&per_page=20&order=status&direction=desc&match=all"
  local _CLOUDFLARE_REQUEST_ARGS="${_CLOUDFLARE_ENDPOINT}${_CLOUDFLARE_REQUEST_PARAM_ZONE}${_CLOUDFLARE_REQUEST_PARAM}"

  local _CLOUDFLARE_DOMAIN_INFO=$(${_CURL} -s -X GET "${_CLOUDFLARE_REQUEST_ARGS}" \
  -H "X-Auth-Email: ${_CLOUDFLARE_CLIENT_EMAIL}" \
  -H "X-Auth-Key: ${_CLOUDFLARE_TOKEN}" \
  -H "Content-Type: application/json")

  if [[ ${_CLOUDFLARE_DOMAIN_INFO:11:5} == "false" ]]; then

    echo ${_CLOUDFLARE_DOMAIN_INFO}
    raise RequiredConfigNotFound "[cloudflare_domain_info] Invalid request headers or Invalid format."

  fi

  echo ${_CLOUDFLARE_DOMAIN_INFO}

}

function cloudflare_domain_hash() {

  local _CLOUDFLARE_DOMAIN=${1}
  if [ -z ${_CLOUDFLARE_DOMAIN:-} ]; then

    raise RequiredConfigNotFound "[cloudflare_domain_hash] Please provaid a valid domain."

  fi

 local _CLOUDFLARE_DOMAIN_INFO=$(cloudflare_domain_info ${_CLOUDFLARE_DOMAIN})
 if [[ ${_CLOUDFLARE_DOMAIN_INFO:11:5} == "false" ]]; then

   echo ${_CLOUDFLARE_DOMAIN_INFO}
   raise RequiredConfigNotFound "[cloudflare_domain_hash] Invalid request headers or Invalid format."

 fi

 # Get only site hash
 local _CLOUDFLARE_DOMAIN_HASH=${_CLOUDFLARE_DOMAIN_INFO:18:32}
 echo ${_CLOUDFLARE_DOMAIN_HASH}

}
