#!/usr/bin/env bash

function migrate_dns_del_acquia_domains() {

  if [ -z ${1:-} ]; then

    raise RequiredParameterNotFound "[migrate_dns_del_acquia_domains] Please provide a valid domain"

  else

    local _MIGRATE_DNS_DEL_DOMAIN=${1}

  fi

  if (! migrate_dns_check_domain_exists "${_MIGRATE_DNS_DEL_DOMAIN}"); then

    out_warning "${_MIGRATE_DNS_DEL_DOMAIN} is not present in target Acquia subscription - Ignoring"

  else

    out_info "Deleting ${_MIGRATE_DNS_DEL_DOMAIN} from ${_MIGRATE_DNS_SUB_DOT_ENV}" 1
    ${_DRUSH} @${_MIGRATE_DNS_SUB_DOT_ENV} ac-domain-delete ${_MIGRATE_DNS_DEL_DOMAIN}
    out_check_status $? "Domain ${_MIGRATE_DNS_DEL_DOMAIN} removed successfully" "Fail to remove domain ${_MIGRATE_DNS_DEL_DOMAIN}"

  fi

}

function migrate_dns_add_acquia_domains() {

  if [ -z ${1:-} ]; then

    raise RequiredParameterNotFound "[migrate_dns_add_acquia_domains] Please provide a valid domain"

  else

    local _MIGRATE_DNS_ADD_DOMAIN=${1}

  fi

  if (migrate_dns_check_domain_exists "${_MIGRATE_DNS_ADD_DOMAIN}"); then

    out_warning "${_MIGRATE_DNS_ADD_DOMAIN} is already present in target Acquia subscription - Ignoring"

  else

    out_info "Adding ${_MIGRATE_DNS_ADD_DOMAIN} to ${_MIGRATE_DNS_SUB_DOT_ENV}" 1
    ${_DRUSH} @${_MIGRATE_DNS_SUB_DOT_ENV} ac-domain-add ${_MIGRATE_DNS_ADD_DOMAIN}
    out_check_status $? "Domain ${_MIGRATE_DNS_ADD_DOMAIN} added successfully" "Fail to add domain ${_MIGRATE_DNS_ADD_DOMAIN}"

  fi

}

function migrate_dns_check_domain_exists() {

  if [ -z ${1:-} ]; then

    return 1

  else

    local _MIGRATE_DNS_CHECK_DOMAIN=${1}

  fi

  if (echo ${_MIGRATE_DNS_FOUND_DOMAINS} | sed "s/ /\n/g" | egrep -q "^${_MIGRATE_DNS_CHECK_DOMAIN}$"); then

    return 0

  else

    return 1

  fi

}
