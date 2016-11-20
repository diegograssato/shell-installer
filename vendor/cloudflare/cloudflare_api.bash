#!/usr/bin/env bash

function cloudflare_domain_purge() {

  local _CLOUDFLARE_DOMAIN=${1}
  if [ -z ${_CLOUDFLARE_DOMAIN:-} ]; then

    raise RequiredConfigNotFound "[cloudflare_domain_purge] Please provaid a valid domain."

  fi

 local _CLOUDFLARE_DOMAIN_HASH=$(cloudflare_domain_hash ${_CLOUDFLARE_DOMAIN})
 if [[ ${_CLOUDFLARE_DOMAIN_HASH:11:5} == "false" ]]; then

   raise RequiredConfigNotFound "[cloudflare_domain_purge] Invalid request headers or Invalid format."

 fi

 if [ -z ${_CLOUDFLARE_ENDPOINT:-} ]; then

   raise RequiredConfigNotFound "[cloudflare_domain_purge] Please configure variable _CLOUDFLARE_ENDPOINT in configuration file [config/cloudlare_config.bash]."

 fi

 if [ -z ${_CLOUDFLARE_CLIENT_EMAIL:-} ]; then

   raise RequiredConfigNotFound "[cloudflare_domain_purge] Please configure variables _CLOUDFLARE_CLIENT_EMAIL in configuration file [config/cloudlare_config.bash]."

 fi

 if [ -z ${_CLOUDFLARE_TOKEN:-} ]; then

   raise RequiredConfigNotFound "[cloudflare_domain_purge] Please configure variables _CLOUDFLARE_TOKEN in configuration file [config/cloudlare_config.bash]."

 fi

 local _CLOUDFLARE_REQUEST_PARAM_ZONE="/zones/${_CLOUDFLARE_DOMAIN_HASH}/purge_cache"
 local _CLOUDFLARE_REQUEST_ARGS="${_CLOUDFLARE_ENDPOINT}${_CLOUDFLARE_REQUEST_PARAM_ZONE}"

 ${_CURL} -s -X DELETE "${_CLOUDFLARE_REQUEST_ARGS}" \
          -H "X-Auth-Email: ${_CLOUDFLARE_CLIENT_EMAIL}" \
          -H "X-Auth-Key: ${_CLOUDFLARE_TOKEN}" \
          -H "Content-Type: application/json" \
          --data '{"purge_everything":true}'
  echo
  
}
