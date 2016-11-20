#!/usr/bin/env bash

# Use YAY yml loader
function subscription_configuration_get_platforms_same_version() {

  local _PLATFORM_VERSION=${1:-}
  shift 1
  local _SUBSCRIPTION_CONFIGURATION_GET_ALL_SUBSCRIPTION=${@}
  local _LIST_PLATFORM_SAME_VERSION=""

  for _SUBSCRIPTION in ${_SUBSCRIPTION_CONFIGURATION_GET_ALL_SUBSCRIPTION}; do

    local _VERSION=$(subscription_configuration_get_plat_repo_resource ${_SUBSCRIPTION})
    if [ ${_VERSION} == ${_PLATFORM_VERSION} ]; then

      if (! in_list? ${_SUBSCRIPTION} "${_LIST_PLATFORM_SAME_VERSION[@]}"); then

        _LIST_PLATFORM_SAME_VERSION="${_LIST_PLATFORM_SAME_VERSION[@]} ${_SUBSCRIPTION}"

      fi

    fi

  done

  # Check exists platform
  local _CHECK_SIZE_PLATFORM_SAME_VERSION="$(echo ${_LIST_PLATFORM_SAME_VERSION:-} |wc -w)"

  if [ ${_CHECK_SIZE_PLATFORM_SAME_VERSION} -gt 0 ]; then

    local _LIST_PLATFORM_SAME_VERSION=("${_LIST_PLATFORM_SAME_VERSION}")

    if [ ${#_LIST_PLATFORM_SAME_VERSION[@]} -ge 1 ]; then

      echo ${_LIST_PLATFORM_SAME_VERSION[@]}

    fi

  fi

}

# Use YAY yml loader
function subscription_configuration_get_sites_in_same_platform_version() {

  local _LOCAL_SETUP_PLATFORM_SAME_VERSION=${@}
  local _LIST_SUBSITES_IN_SUBSCRIPTION=""

  for _SUBSCRIPTION in ${_LOCAL_SETUP_PLATFORM_SAME_VERSION}; do

    local _OLD_SITES=$(subscription_configuration_get_sites ${_SUBSCRIPTION})

    for _SUBSITE in ${_OLD_SITES}; do

      if (! in_list? ${_SUBSITE} "${_LIST_SUBSITES_IN_SUBSCRIPTION[@]}"); then

        _LIST_SUBSITES_IN_SUBSCRIPTION="${_LIST_SUBSITES_IN_SUBSCRIPTION[@]} ${_SUBSITE}"

      fi

    done

  done

  # Check exists subsite
  local _CHECK_SIZE_SUBSITES_IN_SUBSCRIPTION="$(echo ${_LIST_SUBSITES_IN_SUBSCRIPTION:-} |wc -w)"

  if [ ${_CHECK_SIZE_SUBSITES_IN_SUBSCRIPTION} -gt 0 ]; then

    local _LIST_SUBSITES_IN_SUBSCRIPTION=("${_LIST_SUBSITES_IN_SUBSCRIPTION}")

    if [ ${#_LIST_SUBSITES_IN_SUBSCRIPTION[@]} -ge 1 ]; then

      echo ${_LIST_SUBSITES_IN_SUBSCRIPTION[@]}

    fi

  fi

}

function subscription_configuration_check_site_exists_in_sub() {

  local _SUBSCRIPTION=${1:-}
  local _SUBSITE=${2:-}

  if [ -z ${_SUBSCRIPTION} ]; then

    raise RequiredParameterNotFound "[subscription_configuration_check_site_exists_in_sub] Please provide a valid subscription"

  fi

  if [ -z ${_SUBSITE} ]; then

    raise RequiredParameterNotFound "[subscription_configuration_check_site_exists_in_sub] Please provide a valid subsite"

  fi

  _SUBSCRIPTION_SITES=$(subscription_configuration_get_sites ${_SUBSCRIPTION})

  if (in_list? ${_SUBSITE} "${_SUBSCRIPTION_SITES[@]}"); then

    return 1

  fi

  return 0

}

function subscription_configuration_check_subsite() {

  local _SUBSCRIPTION=${1:-}
  local _SUBSITE=${2:-}

  if (subscription_configuration_check_site_exists_in_sub ${_SUBSCRIPTION} ${_SUBSITE}); then

    local _GET_SITES=$(subscription_configuration_get_sites ${_SUBSCRIPTION})

    out_danger "Site '${_SUBSITE}' not exists, select one from the list:" 1
    for SITE in ${_GET_SITES}; do

      echo -e "  ${BGREEN} ${SITE} ${COLOR_OFF}"

    done

    raise RequiredSiteNotFound "[subscription_configuration_check_subsite] Site '${_SUBSITE}' does not exist, please provid a valid site"

  fi

}

function subscription_configuration_get_platform_path() {

  local _SUBSCRIPTION=${1:-}

  if [ -z ${_SUBSCRIPTION} ]; then

    raise MissingRequiredConfig "[subscription_configuration_get_platform_path] Please provide a valid subscription"

  fi

  local _PLATFORM_ACQUIA_BRANCH=$(subscription_configuration_get_plat_repo_resource ${_SUBSCRIPTION})
  local _PLATFORM_ACQUIA_BRANCH_OUT=${_PLATFORM_ACQUIA_BRANCH/\//-}
  _PLATFORM_ACQUIA_BRANCH_OUT=${_PLATFORM_ACQUIA_BRANCH_OUT^^}

  echo ${_PLATFORM_ACQUIA_BRANCH_OUT}

}

function subscription_configuration_get_prod_subscriptions() {

  local _SUBSCRIPTION_CONFIGURATION_PROD_SUBS=""
  local _SUBSCRIPTION_CONFIGURATION_ALL_SUBSCRIPTION=$(subscription_configuration_get_all_subscriptions)

  for _SUBSCRIPTION in ${_SUBSCRIPTION_CONFIGURATION_ALL_SUBSCRIPTION}; do

    local _IS_PROD=$(subscription_configuration_get_production ${_SUBSCRIPTION})

    if [ "${_IS_PROD}" == "true" ]; then

      _SUBSCRIPTION_CONFIGURATION_PROD_SUBS="${_SUBSCRIPTION_CONFIGURATION_PROD_SUBS} ${_SUBSCRIPTION}"

    fi

  done

  echo ${_SUBSCRIPTION_CONFIGURATION_PROD_SUBS}

}
