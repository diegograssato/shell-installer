#!/usr/bin/env bash

# Get repository from subscription
function subscription_configuration_get_repository() {

  local _SUBSCRIPTION=${1:-}

  if [ -z ${_SUBSCRIPTION} ]; then

    raise RequiredParameterNotFound "[subscription_configuration_get_repository] Please provide a valid subscription"

  fi

  _CHECK_SUBSCRIPTION_REPO=$(printf "_SUBSCRIPTIONS_%s_PLATFORM_REPO" ${_SUBSCRIPTION^^})

  if [ ! -z ${!_CHECK_SUBSCRIPTION_REPO:-} ]; then

    echo ${!_CHECK_SUBSCRIPTION_REPO}

  fi

}

# Get platform name from subscription
function subscription_configuration_get_repository_name() {

  local _SUBSCRIPTION=${1:-}

  if [ -z ${_SUBSCRIPTION} ]; then

    raise RequiredParameterNotFound "[subscription_configuration_get_name] Please provide a valid subscription"

  fi

  _CHECK_SUBSCRIPTION_REPO=$(printf "_SUBSCRIPTIONS_%s_PLATFORM_REPO_NAME" ${_SUBSCRIPTION^^})

  if [ ! -z ${!_CHECK_SUBSCRIPTION_REPO:-} ]; then

    echo ${!_CHECK_SUBSCRIPTION_REPO}

  fi

}

# Get branch from subscription
function subscription_configuration_get_plat_repo_resource() {

  local _SUBSCRIPTION=${1:-}

  if [ -z ${_SUBSCRIPTION} ]; then

    raise RequiredParameterNotFound "[subscription_configuration_get_plat_repo_resource] Please provide a valid subscription"

  fi

  _CHECK_SUBSCRIPTION_SOURCE_ENV=$(printf "_SUBSCRIPTIONS_%s_PLATFORM_REPO_RESOURCE" ${_SUBSCRIPTION^^})

  if [ ! -z ${!_CHECK_SUBSCRIPTION_SOURCE_ENV:-} ]; then

   echo ${!_CHECK_SUBSCRIPTION_SOURCE_ENV}

  fi

}

# Get acquia repository from subscription
function subscription_configuration_get_acquia_repo() {

  local _SUBSCRIPTION=${1:-}

  if [ -z ${_SUBSCRIPTION} ]; then

    raise RequiredParameterNotFound "[subscription_configuration_get_acquia_repo] Please provide a valid subscription"

  fi

  _CHECK_SUBSCRIPTION_ACQUIA_REPO=$(printf "_SUBSCRIPTIONS_%s_ACQUIA_REPO" ${_SUBSCRIPTION^^})

  if [ ! -z ${!_CHECK_SUBSCRIPTION_ACQUIA_REPO:-} ]; then

    echo ${!_CHECK_SUBSCRIPTION_ACQUIA_REPO}

  fi

}

# Get acquia repository resource from subscription
function subscription_configuration_get_acquia_repo_resource() {

  local _SUBSCRIPTION=${1:-}

  if [ -z ${_SUBSCRIPTION} ]; then

    raise RequiredParameterNotFound "[subscription_configuration_get_acquia_repo_resource] Please provide a valid subscription"

  fi

  _CHECK_SUBSCRIPTION_ACQUIA_REPO_RES=$(printf "_SUBSCRIPTIONS_%s_ACQUIA_REPO_RESOURCE" ${_SUBSCRIPTION^^})

  if [ ! -z ${!_CHECK_SUBSCRIPTION_ACQUIA_REPO_RES:-} ]; then

   echo ${!_CHECK_SUBSCRIPTION_ACQUIA_REPO_RES}

  fi

}

# Get sites from subscription
function subscription_configuration_get_sites() {

  local _SUBSCRIPTION=${1:-}

  if [ -z ${_SUBSCRIPTION} ]; then

    raise RequiredParameterNotFound "[subscription_configuration_get_sites] Please provide a valid subscription"

  fi

  local _LIST_SUBSITES_IN_SUBSCRIPTION=$(printf "_SUBSCRIPTIONS_%s_SITES[@]" ${_SUBSCRIPTION^^})
  local _LIST_SIZE_SUBSITES_IN_SUBSCRIPTION="$(echo ${!_LIST_SUBSITES_IN_SUBSCRIPTION:-} | wc -w)"

  if [ ${_LIST_SIZE_SUBSITES_IN_SUBSCRIPTION} -gt 0 ]; then

    local _LIST_SUBSITES_IN_SUBSCRIPTION=("${!_LIST_SUBSITES_IN_SUBSCRIPTION}")

    if [ ${#_LIST_SUBSITES_IN_SUBSCRIPTION[@]} -ge 1 ]; then

      echo ${_LIST_SUBSITES_IN_SUBSCRIPTION[@]}

    fi

  fi

}

# Use YAY yml loader
function subscription_configuration_get_all_subscriptions {

  local _LIST_SUBSCRIPTION=$(printf "__SUBSCRIPTIONS[@]")
  local _LIST_SIZE_SUBSCRIPTION="$(echo ${!_LIST_SUBSCRIPTION:-} | wc -w)"

  if [ ${_LIST_SIZE_SUBSCRIPTION} -gt 0 ]; then

    local _LIST_SUBSCRIPTION=("${!_LIST_SUBSCRIPTION}")

    if [ ${#_LIST_SUBSCRIPTION[@]} -ge 1 ]; then

      echo ${_LIST_SUBSCRIPTION[@]} |sed -e "s/ /\n/g" |sed -e "s/^_//g" |sed -e "s/^_//g"

    fi

  else

    raise RequiredConfigNotFound "[subscription_configuration_get_all_subscriptions] Please load appropriate yml file "

  fi

}

function subscription_configuration_get_production() {

  local _SUBSCRIPTION=${1:-}
  local _PRODUCTION=$(printf "_SUBSCRIPTIONS_%s_PRODUCTION" ${_SUBSCRIPTION^^})

  if [ ! -z ${!_PRODUCTION:-} ] && [[ "${!_PRODUCTION:-}" == "true" ]]; then

    echo ${!_PRODUCTION}

  fi

}

function subscription_configuration_get_region() {

  local _SUBSCRIPTION=${1:-}

  if [ -z ${_SUBSCRIPTION} ]; then

    raise RequiredParameterNotFound "[subscription_configuration_get_region] Please provide a valid subscription"

  fi

  _CHECK_SUBSCRIPTION_REGION=$(printf "_SUBSCRIPTIONS_%s_REGION" ${_SUBSCRIPTION^^})

  if [ ! -z ${!_CHECK_SUBSCRIPTION_REGION:-} ]; then

    echo ${!_CHECK_SUBSCRIPTION_REGION}

  fi

}
