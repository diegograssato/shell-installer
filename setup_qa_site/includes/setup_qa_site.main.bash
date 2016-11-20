#!/usr/bin/env bash


function setup_qa_site_load_configurations() {

  if [ -z ${1:-} ]; then

    raise RequiredParameterNotFound "[setup_qa_site_load_configurations] Please provide a valid site"

  else

    _SETUP_QA_SITE_SUBSITE=${1}

  fi

  if [ -z ${2:-} ]; then

    raise RequiredParameterNotFound "[setup_qa_site_load_configurations] Please provide a valid subscription"

  else

    _SETUP_QA_SITE_SUBSCRIPTION=${2}

  fi

  local _YML_SUBSCRIPTION_FILE_CONFIGURATION="${SF_SCRIPTS_HOME}/config/subscriptions.yml"
  local _YML_SUBSCRIPTION_FILE_SUBSITE="${SF_SCRIPTS_HOME}/config/${_SETUP_QA_SITE_SUBSCRIPTION:-}.yml"

  if [ ! -f "${_YML_SUBSCRIPTION_FILE_CONFIGURATION}" ]; then

    raise FileNotFound "[setup_qa_site_load_configurations] File ${_YML_SUBSCRIPTION_FILE_CONFIGURATION} not found!"

  else

    eval $(yml_loader ${_YML_SUBSCRIPTION_FILE_CONFIGURATION} "_")

  fi

  if [ -z "${_YML_SUBSCRIPTION_FILE_SUBSITE}" ]; then

    raise FileNotFound "[setup_qa_site_load_configurations] File ${_YML_SUBSCRIPTION_FILE_SUBSITE} not found!"

  else

    eval $(yml_loader ${_YML_SUBSCRIPTION_FILE_SUBSITE} "_")

  fi

  out_warning "Loading configurations" 1

  # Setup initials variables
  _SETUP_QA_SITE_SUBSITE_REPO=$(site_configuration_get_subsite_repo ${_SETUP_QA_SITE_SUBSITE} ${_SETUP_QA_SITE_SUBSCRIPTION})
  _SETUP_QA_SITE_SUBSITE_BRANCH=$(site_configuration_get_subsite_branch ${_SETUP_QA_SITE_SUBSITE} ${_SETUP_QA_SITE_SUBSCRIPTION})
  _SETUP_QA_SITE_REAL_NAME=$(site_configuration_get_subsite_name ${_SETUP_QA_SITE_SUBSITE} ${_SETUP_QA_SITE_SUBSCRIPTION})

  _SETUP_QA_SITE_PLATFORM_PLATFORM_REPO=$(subscription_configuration_get_repository ${_SETUP_QA_SITE_SUBSCRIPTION})
  _SETUP_QA_SITE_PLATFORM_ACQUIA_BRANCH=$(subscription_configuration_get_plat_repo_resource ${_SETUP_QA_SITE_SUBSCRIPTION})
  _SETUP_QA_SITE=$(subscription_configuration_get_sites ${_SETUP_QA_SITE_SUBSCRIPTION})

  # Setup others variables
  _SETUP_QA_SITE_SUBSITE_PATH="${_SETUP_QA_SITE_WORKSPACE}/sites/${_SETUP_QA_SITE_SUBSITE}"
  _SETUP_QA_SITE_SUBSCRIPTION_PATH="${_SETUP_QA_SITE_WORKSPACE}/subscriptions/${_SETUP_QA_SITE_SUBSCRIPTION}"

}

function setup_qa_site_create_subsite_vhost() {

  out_warning "Setting up virtual hosts for QA sites" 1

  local _SETUP_QA_SITE_APACHE_SUBSCRIPTION_PATH="${_SETUP_QA_SITE_APACHE_PATH}/${_SETUP_QA_SITE_SUBSCRIPTION}/docroot"
  local _SETUP_QA_SITE_APACHE_SUBSITE_PATH="${_SETUP_QA_SITE_APACHE_SUBSCRIPTION_PATH}/sites/${_SETUP_QA_SITE_REAL_NAME}"
  local _SETUP_QA_SITE_DOMAIN_LIST=$(site_configuration_get_subscription_domains ${_SETUP_QA_SITE_SUBSCRIPTION} "qa")

  # Generate vitualhost based macro
  apache_generate_vhost_macro ${_SETUP_QA_SITE_APACHE_SUBSCRIPTION_PATH} ${_SETUP_QA_MACRO_VHOSTS} ${_SETUP_QA_SITE_DOMAIN_LIST}

  # Reload apache
  apache_reload

}

function setup_qa_site_dns() {

  out_warning "Setting up QA site DNS" 1

  local _SETUP_QA_SITE_DNS_LIST=$(setup_qa_site_dns_urls ${_SETUP_QA_SITE_SUBSCRIPTION} ${_SETUP_QA_SITE_SUBSITE})

  for _SETUP_QA_SITE_URL in ${_SETUP_QA_SITE_DNS_LIST}; do

    dns_delete_url ${_SETUP_QA_SITE_URL}
    setup_qa_site_dns_add ${_SETUP_QA_SITE_URL}

  done

}
