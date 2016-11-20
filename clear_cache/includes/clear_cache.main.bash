#!/usr/bin/env bash

function clear_cache_load_configurations() {

  if [ -z ${1:-} ]; then

    raise RequiredParameterNotFound "[clear_cache_load_configurations] Please provide a valid subscription"

  else

    _CLEAR_CACHE_SUBSCRIPTION=${1}

  fi

  if [ -z ${2:-} ]; then

    raise RequiredParameterNotFound "[clear_cache_load_configurations] Please provide a valid environment"

  else

    _CLEAR_CACHE_ENV=${2}

  fi

  if [ -z ${3:-} ]; then

    raise RequiredParameterNotFound "[clear_cache_load_configurations] Please provide a valid subsite"

  else

    _CLEAR_CACHE_SUBSITE=${3}

  fi

  if [ -z ${4:-} ]; then

    _CLEAR_CACHE_DRUPAL="true"

  else

    _CLEAR_CACHE_DRUPAL=${4}

  fi

  if [ -z ${5:-} ]; then

    _CLEAR_CACHE_MEMCACHE="true"

  else

    _CLEAR_CACHE_MEMCACHE=${5}

  fi

  if [ -z ${6:-} ]; then

    _CLEAR_CACHE_VARNISH="true"

  else

    _CLEAR_CACHE_VARNISH=${6}

  fi

  if [[ -n ${7:-} ]] && [[ ${7:-} == "true" ]] && [[ ${_CLEAR_CACHE_ENV} == "prod" ]]; then

    _CLEAR_CACHE_CDN="true"

  else

    _CLEAR_CACHE_CDN="false"

  fi

  out_warning "Loading configurations" 1

  local _CLEAR_CACHE_YML_SUBSCRIPTION_FILE_CONFIGURATION="${SF_SCRIPTS_HOME}/config/subscriptions.yml"
  local _CLEAR_CACHE_YML_SUBSCRIPTION_FILE_SUBSITE="${SF_SCRIPTS_HOME}/config/${_CLEAR_CACHE_SUBSCRIPTION:-}.yml"

  if [ ! -f "${_CLEAR_CACHE_YML_SUBSCRIPTION_FILE_CONFIGURATION}" ]; then

    raise FileNotFound "[clear_cache_load_configurations] File ${_CLEAR_CACHE_YML_SUBSCRIPTION_FILE_CONFIGURATION} not found!"

  else

    eval $(yml_loader ${_CLEAR_CACHE_YML_SUBSCRIPTION_FILE_CONFIGURATION} "_")

  fi

  if [ ! -f "${_CLEAR_CACHE_YML_SUBSCRIPTION_FILE_SUBSITE}" ]; then

    raise FileNotFound "[clear_cache_load_configurations] Missing configuration file ${_CLEAR_CACHE_YML_SUBSCRIPTION_FILE_SUBSITE}"

  else

    eval $(yml_loader ${_CLEAR_CACHE_YML_SUBSCRIPTION_FILE_SUBSITE} "_")

  fi

  subscription_configuration_check_subsite ${_CLEAR_CACHE_SUBSCRIPTION} ${_CLEAR_CACHE_SUBSITE}

  if [ ${_CLEAR_CACHE_CDN} == "true" ]; then

    local _CLEAR_CACHE_DOMAINS=$(site_configuration_get_domains ${_CLEAR_CACHE_SUBSCRIPTION} ${_CLEAR_CACHE_ENV} ${_CLEAR_CACHE_SUBSITE})
    _CLEAR_CACHE_DOMAIN=$(echo "${_CLEAR_CACHE_DOMAINS}" | ${_SED} -e "s/\s/\n/g" | ${_GREP} "^www" | head -1)

  fi

  # Define script variables
  _CLEAR_CACHE_SUBSITE_REAL_NAME=$(site_configuration_get_subsite_name ${_CLEAR_CACHE_SUBSITE} ${_CLEAR_CACHE_SUBSCRIPTION})

}

function clear_cache_init() {

  metrics_add ${_CLEAR_CACHE_SUBSITE}
  metrics_add ${_CLEAR_CACHE_SUBSCRIPTION}
  metrics_add ${_CLEAR_CACHE_ENV}
  metrics_add ${_CLEAR_CACHE_DRUPAL}
  metrics_add ${_CLEAR_CACHE_MEMCACHE}
  metrics_add ${_CLEAR_CACHE_VARNISH}
  metrics_add ${_CLEAR_CACHE_CDN}

}


function clear_cache_drupal() {

  if [ ${_CLEAR_CACHE_DRUPAL} == "true" ]; then

    acquia_clear_drupal_cache ${_CLEAR_CACHE_SUBSCRIPTION} ${_CLEAR_CACHE_ENV} ${_CLEAR_CACHE_SUBSITE}

  fi

}

function clear_cache_memcache() {

  if [ ${_CLEAR_CACHE_MEMCACHE} == "true" ]; then

    out_warning "Clearing Memcached cache of ${_CLEAR_CACHE_SUBSCRIPTION}.${_CLEAR_CACHE_ENV}" 1
    acquia_clear_memcache ${_CLEAR_CACHE_SUBSCRIPTION} ${_CLEAR_CACHE_ENV}
    out_check_status $? "Memcached cache cleared successfully." "Error on clear Memcached cache." 1

  fi

}

function clear_cache_varnish() {

  if [ ${_CLEAR_CACHE_VARNISH} == "true" ]; then

    out_warning "Clearing Varnish cache of ${_CLEAR_CACHE_SUBSCRIPTION}.${_CLEAR_CACHE_ENV}" 1
    acquia_clear_varnish ${_CLEAR_CACHE_SUBSCRIPTION} ${_CLEAR_CACHE_ENV} ${_CLEAR_CACHE_SUBSITE} || true

  fi

}

function clear_cache_cdn() {

  if [ ${_CLEAR_CACHE_CDN} == "true" ]; then

    out_warning "Clearing CDN cache of ${_CLEAR_CACHE_DOMAIN}" 1
    cloudflare_domain_purge ${_CLEAR_CACHE_DOMAIN}
    out_check_status $? "CDN cache cleared successfully." "Error on clear CDN cache." 1

  fi

}
