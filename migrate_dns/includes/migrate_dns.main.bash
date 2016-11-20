#!/usr/bin/env bash

function migrate_dns_load_configurations() {

  if [ -z ${1:-} ]; then

    raise RequiredParameterNotFound "[migrate_dns_load_configurations] Please provide a valid operation"

  elif [ ${1} != 'add' ] && [ ${1} != 'del' ]; then

    raise InvalidParameter "Invalid parameter provided. Valid options: 'add' or 'del'"

  else

    _MIGRATE_DNS_OPERATION=${1}

  fi

  if [ -z ${2:-} ]; then

    raise RequiredParameterNotFound "[migrate_dns_load_configurations] Please provide a valid subscription"

  else

    _MIGRATE_DNS_SUBSCRIPTION=${2}

  fi

  if [ -z ${3:-} ]; then

    raise RequiredParameterNotFound "[migrate_dns_load_configurations] Please provide a valid site environment"

  else

    _MIGRATE_DNS_ENVIRONMENT=${3}

  fi

  shift 3

  if [[ -z ${@} ]]; then

    raise RequiredParameterNotFound "[migrate_dns_load_configurations] Domains not found"

  else

    _MIGRATE_DNS_PROVIDED_DOMAINS=$@

  fi

  out_warning "Loading script parameters" 1

  _MIGRATE_DNS_SUB_DOT_ENV="${_MIGRATE_DNS_SUBSCRIPTION}.${_MIGRATE_DNS_ENVIRONMENT}"

  out_info "Fetching domains configured in ${_MIGRATE_DNS_SUB_DOT_ENV}"
  _MIGRATE_DNS_FOUND_DOMAINS=$(drush_ac_domain_list ${_MIGRATE_DNS_SUBSCRIPTION} ${_MIGRATE_DNS_ENVIRONMENT})
  local _MIGRATE_DNS_REQUEST_RESULT=$?
  local _MIGRATE_DNS_FOUND_DOMAINS_COUNT=$(echo ${_MIGRATE_DNS_FOUND_DOMAINS} | sed "s/ /\n/g" | wc -l)
  out_check_status ${_MIGRATE_DNS_REQUEST_RESULT} "${_MIGRATE_DNS_FOUND_DOMAINS_COUNT} URLs found in ${_MIGRATE_DNS_SUB_DOT_ENV}" "Error fetching Acquia domains"

}

function migrate_dns_exec() {

  for _DOMAIN in ${_MIGRATE_DNS_PROVIDED_DOMAINS}; do

    if [ ${_MIGRATE_DNS_OPERATION} == 'add' ]; then

      migrate_dns_add_acquia_domains "${_DOMAIN}"

    elif [ ${_MIGRATE_DNS_OPERATION} == 'del' ]; then

      migrate_dns_del_acquia_domains "${_DOMAIN}"

    fi

  done

}
