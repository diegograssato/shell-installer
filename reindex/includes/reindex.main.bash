#!/usr/bin/env bash

function reindex_load_configurations() {

  if [ -z ${1:-} ]; then

    raise RequiredParameterNotFound "[reindex_load_configurations] Please provide a valid subscription"

  else

    _REINDEX_SUBSCRIPTION=${1}

  fi

  if [ -z ${2:-} ]; then

    raise RequiredParameterNotFound "[reindex_load_configurations] Please provide a valid environment"

  else

    _REINDEX_ENV=${2}

  fi

  if [ -z ${3:-} ]; then

    raise RequiredParameterNotFound "[reindex_load_configurations] Please provide a valid subsite"

  else

    _REINDEX_SUBSITE=${3}

  fi

  if [ -z ${4:-} ]; then

    _REINDEX_SOLR="true"

  else

    _REINDEX_SOLR=${4}

  fi

  if [ -z ${5:-} ]; then

    _REINDEX_SITEMAP="true"

  else

    _REINDEX_SITEMAP=${5}

  fi

  if [ -z ${6:-} ]; then

    _REINDEX_BV="false"

  else

    _REINDEX_BV=${6}

  fi

  if [[ -n ${7:-} ]] && [[ ${7:-} == "true" ]] && [[ ${_REINDEX_ENV} == "prod" ]]; then

    _REINDEX_CDN="true"

  else

    _REINDEX_CDN="false"

  fi

  out_warning "Loading configurations" 1

  local _REINDEX_YML_SUBSCRIPTION_FILE_CONFIGURATION="${SF_SCRIPTS_HOME}/config/subscriptions.yml"
  local _REINDEX_YML_SUBSCRIPTION_FILE_SUBSITE="${SF_SCRIPTS_HOME}/config/${_REINDEX_SUBSCRIPTION:-}.yml"
  if [ ! -f "${_REINDEX_YML_SUBSCRIPTION_FILE_CONFIGURATION}" ]; then

    raise FileNotFound "[reindex_load_configurations] File ${_REINDEX_YML_SUBSCRIPTION_FILE_CONFIGURATION} not found!"

  fi

  if [ ! -f "${_REINDEX_YML_SUBSCRIPTION_FILE_SUBSITE}" ]; then

    raise FileNotFound "[reindex_load_configurations] Missing configuration file ${_REINDEX_YML_SUBSCRIPTION_FILE_SUBSITE}"

  fi


  if [ -z ${8:-} ]; then

    eval $(yml_loader ${_REINDEX_YML_SUBSCRIPTION_FILE_CONFIGURATION} "_")
    eval $(yml_loader ${_REINDEX_YML_SUBSCRIPTION_FILE_SUBSITE} "_")
    subscription_configuration_check_subsite ${_REINDEX_SUBSCRIPTION} ${_REINDEX_SUBSITE}

    case ${_REINDEX_ENV} in
      "prod"|"test"|"dev")
        _REINDEX_SUBSITE_DOMAINS=$(site_configuration_get_domains ${_REINDEX_SUBSCRIPTION} ${_REINDEX_ENV} ${_REINDEX_SUBSITE})
        ;;
      *)
        raise InvalidParameter "[reindex_load_configurations] Please provide a valid environment: dev, test or prod"
        ;;
    esac

    # Define script variables
    _REINDEX_SUBSITE_DOMAIN=$(echo "${_REINDEX_SUBSITE_DOMAINS}" | ${_SED} -e "s/\s/\n/g" | ${_GREP} "^con\|^www" | head -1)
    local _REINDEX_SSL=$(site_configuration_get_subsite_ssl "${_REINDEX_SUBSCRIPTION}" "${_REINDEX_SUBSITE}")
    if [ "${_REINDEX_SSL}" == "true" ]; then

      out_warning "Reindexing URLs with SSL" 1

      _REINDEX_SUBSITE_DOMAIN="https://${_REINDEX_SUBSITE_DOMAIN}"

    fi

    _REINDEX_SUBSITE_REAL_NAME=$(site_configuration_get_subsite_name ${_REINDEX_SUBSITE} ${_REINDEX_SUBSCRIPTION})

  else

    shift 7
    _REINDEX_SUBSITE_DOMAINS=${@}
    _REINDEX_SUBSITE_REAL_NAME=${_REINDEX_SUBSITE}
    _REINDEX_SUBSITE_DOMAIN=$(echo "${_REINDEX_SUBSITE_DOMAINS}" | cut -f1)

  fi

  # Define script variables
  _REINDEX_SUB_DOT_ENV="${_REINDEX_SUBSCRIPTION}.${_REINDEX_ENV}"

}

function reindex_metrics_init() {

  metrics_add ${_REINDEX_SUBSITE}
  metrics_add ${_REINDEX_SUBSCRIPTION}
  metrics_add ${_REINDEX_ENV}
  metrics_add ${_REINDEX_BV}
  metrics_add ${_REINDEX_SOLR}
  metrics_add ${_REINDEX_SITEMAP}
  metrics_add ${_REINDEX_CDN}

}

function reindex_clear_cache() {

  local _REINDEX_LIST=""

  if [ ${_REINDEX_BV} == "true" ]; then

    local _REINDEX_LIST="bv"

  fi

  if [ ${_REINDEX_SOLR} == "true" ]; then

    local _REINDEX_LIST="${_REINDEX_LIST} solr"

  fi

  if [ ${_REINDEX_SITEMAP} == "true" ]; then

    local _REINDEX_LIST="${_REINDEX_LIST} sitemap"

  fi

  site_configuration_reindex ${_REINDEX_SUBSCRIPTION} ${_REINDEX_ENV} ${_REINDEX_SUBSITE_REAL_NAME} ${_REINDEX_SUBSITE_DOMAIN} ${_REINDEX_LIST}

}

function reindex_clear_cdn() {

  if [[ "${_REINDEX_CDN}" == "true" ]]; then

    out_warning "Clearing CDN cache of ${_REINDEX_SUBSITE_DOMAIN}" 1
    cloudflare_domain_purge ${_REINDEX_SUBSITE_DOMAIN}
    out_check_status $? "CDN cache cleared successfully." "Error on clear CDN cache." 1

  fi

}

function reindex_clear_varnish() {

  out_warning "Clearing Varnish cache of ${_REINDEX_SUBSCRIPTION}.${_REINDEX_ENV}" 1
  acquia_clear_varnish_for_alternative_domain ${_REINDEX_SUBSCRIPTION} ${_REINDEX_ENV} ${_REINDEX_SUBSITE_DOMAINS} || true

}
