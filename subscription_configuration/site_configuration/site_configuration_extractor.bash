#!/usr/bin/env bash

# Get SubSite name
function site_configuration_get_subsite_name() {

  local _SUB_SITE=${1:-}
  local _SUBSCRIPTION=${2:-}

  if [ -z ${_SUB_SITE} ]; then

    raise RequiredParameterNotFound "[site_configuration_get_subsite_name] Please provide a valid site"

  fi

  if [ -z ${_SUBSCRIPTION} ]; then

    raise RequiredParameterNotFound "[site_configuration_get_subsite_name] Please provide a valid subscription"

  fi

  local _CHECK_SUB_SITE_IN_SITES=$(printf "_%s_%s_SUBSITE" ${_SUBSCRIPTION^^} ${_SUB_SITE^^})

  if [ ! -z ${!_CHECK_SUB_SITE_IN_SITES:-} ]; then

    echo ${!_CHECK_SUB_SITE_IN_SITES}

  fi

}

#Get branch of SubSite
function site_configuration_get_subsite_branch() {

  local _SUB_SITE=${1:-}
  local _SUBSCRIPTION=${2:-}

  if [ -z ${_SUB_SITE} ]; then

    raise RequiredParameterNotFound "[site_configuration_get_subsite_branch] Please provide a valid site"

  fi

  if [ -z ${_SUBSCRIPTION} ]; then

    raise RequiredParameterNotFound "[site_configuration_get_subsite_branch] Please provide a valid subscription"

  fi

  local _CHECK_BRANCH_IN_SITES=$(printf "_%s_%s_BRANCH" ${_SUBSCRIPTION^^} ${_SUB_SITE^^})
  if [ ! -z ${!_CHECK_BRANCH_IN_SITES:-} ]; then

    echo ${!_CHECK_BRANCH_IN_SITES}

  fi

}

#Get subsite ssl parameter status
function site_configuration_get_subsite_ssl() {

  local _SUBSCRIPTION=${1:-}
  local _SUB_SITE=${2:-}
  local _SSL_STATUS=$(printf "_%s_%s_SSL" ${_SUBSCRIPTION^^} ${_SUB_SITE^^})

  if [ ! -z ${!_SSL_STATUS:-} ]; then

    echo ${!_SSL_STATUS}

  fi

}

#Get repository of SubSite
function site_configuration_get_subsite_repo() {

  local _SUB_SITE=${1:-}
  local _SUBSCRIPTION=${2:-}

  if [ -z ${_SUB_SITE} ]; then

    raise RequiredParameterNotFound "[site_configuration_get_subsite_repo] Please provide a valid site"

  fi

  if [ -z ${_SUBSCRIPTION} ]; then

    raise RequiredParameterNotFound "[site_configuration_get_subsite_repo] Please provide a valid subscription"

  fi

  local _CHECK_REPO_IN_SITES=$(printf "_%s_%s_GIT" ${_SUBSCRIPTION^^} ${_SUB_SITE^^})
  if [ ! -z ${!_CHECK_REPO_IN_SITES:-} ]; then

    echo ${!_CHECK_REPO_IN_SITES}

  fi

}

#Get user credential of database
function site_configuration_get_subsite_database_user() {

  local _SUB_SITE=${1:-}
  local _SUBSCRIPTION=${2:-}
  local _ENV=${3:-}

  if [ -z ${_SUB_SITE} ]; then

    raise RequiredParameterNotFound "[site_configuration_get_subsite_database_user] Please provide a valid site"

  fi

  if [ -z ${_SUBSCRIPTION} ]; then

    raise RequiredParameterNotFound "[site_configuration_get_subsite_database_user] Please provide a valid subscription"

  fi

  if [ -z ${_ENV} ]; then

    raise RequiredParameterNotFound "[site_configuration_get_subsite_database_user] Please provide a valid environment"

  fi

  local _CHECK_DATABASE_USER_IN_SITES=$(printf "_%s_%s_DATABASE_%s_USER" ${_SUBSCRIPTION^^} ${_SUB_SITE^^} ${_ENV^^})

  if [ ! -z ${!_CHECK_DATABASE_USER_IN_SITES:-} ]; then

    echo ${!_CHECK_DATABASE_USER_IN_SITES}

  fi

}

#Get password credential of database
function site_configuration_get_subsite_database_password() {

  local _SUB_SITE=${1:-}
  local _SUBSCRIPTION=${2:-}
  local _ENV=${3:-}

  if [ -z ${_SUB_SITE} ]; then

    raise RequiredParameterNotFound "[site_configuration_get_subsite_database_password] Please provide a valid site"

  fi

  if [ -z ${_SUBSCRIPTION} ]; then

    raise RequiredParameterNotFound "[site_configuration_get_subsite_database_password] Please provide a valid subscription"

  fi

  if [ -z ${_ENV} ]; then

    raise RequiredParameterNotFound "[site_configuration_get_subsite_database_password] Please provide a valid environment"

  fi

  local _CHECK_DATABASE_PASS_IN_SITES=$(printf "_%s_%s_DATABASE_%s_PASSWORD" ${_SUBSCRIPTION^^} ${_SUB_SITE^^} ${_ENV^^})
  if [ ! -z ${!_CHECK_DATABASE_PASS_IN_SITES:-} ]; then

    echo ${!_CHECK_DATABASE_PASS_IN_SITES}

  fi

}

#Get host of database
function site_configuration_get_subsite_database_server() {

  local _SUB_SITE=${1:-}
  local _SUBSCRIPTION=${2:-}
  local _ENV=${3:-}

  if [ -z ${_SUB_SITE} ]; then

    raise RequiredParameterNotFound "[site_configuration_get_subsite_database_server] Please provide a valid site"

  fi

  if [ -z ${_SUBSCRIPTION} ]; then

    raise RequiredParameterNotFound "[site_configuration_get_subsite_database_server] Please provide a valid subscription"

  fi

  if [ -z ${_ENV} ]; then

    raise RequiredParameterNotFound "[site_configuration_get_subsite_database_server] Please provide a valid environment"

  fi

  local _CHECK_DATABASE_HOST_IN_SITES=$(printf "_%s_%s_DATABASE_%s_HOST" ${_SUBSCRIPTION^^} ${_SUB_SITE^^} ${_ENV^^})
  if [ ! -z ${!_CHECK_DATABASE_HOST_IN_SITES:-} ]; then

    echo ${!_CHECK_DATABASE_HOST_IN_SITES}

  fi

}

#Get database name
function site_configuration_get_subsite_database_name() {

  local _SUB_SITE=${1:-}
  local _SUBSCRIPTION=${2:-}
  local _ENV=${3:-}

  if [ -z ${_SUB_SITE} ]; then

    raise RequiredParameterNotFound "[site_configuration_get_subsite_database_name] Please provide a valid site"

  fi

  if [ -z ${_SUBSCRIPTION} ]; then

    raise RequiredParameterNotFound "[site_configuration_get_subsite_database_name] Please provide a valid subscription"

  fi

  if [ -z ${_ENV} ]; then

    raise RequiredParameterNotFound "[site_configuration_get_subsite_database_name] Please provide a valid environment"

  fi

  local _CHECK_DATABASE_NAME_IN_SITES=$(printf "_%s_%s_DATABASE_%s_DATABASE" ${_SUBSCRIPTION^^} ${_SUB_SITE^^} ${_ENV^^})
  if [ ! -z ${!_CHECK_DATABASE_NAME_IN_SITES:-} ]; then

    echo ${!_CHECK_DATABASE_NAME_IN_SITES}

  fi

}


#Get database instance
function site_configuration_get_subsite_database_acquia() {

  local _SUB_SITE=${1:-}
  local _SUBSCRIPTION=${2:-}

  if [ -z ${_SUB_SITE} ]; then

    raise RequiredParameterNotFound "[site_configuration_get_subsite_database_acquia] Please provide a valid site"

  fi

  if [ -z ${_SUBSCRIPTION} ]; then

    raise RequiredParameterNotFound "[site_configuration_get_subsite_database_acquia] Please provide a valid subscription"

  fi

  local _CHECK_DATABASE_INSTANCE_IN_SITES=$(printf "_%s_%s_DATABASE_ACQUIA" ${_SUBSCRIPTION^^} ${_SUB_SITE^^})
  if [ ! -z ${!_CHECK_DATABASE_INSTANCE_IN_SITES:-} ]; then

    echo ${!_CHECK_DATABASE_INSTANCE_IN_SITES}

  fi

}

#Get languages from subsite
function site_configuration_get_subsite_languages() {

  local _SUB_SITE=${1:-}
  local _SUBSCRIPTION=${2:-}

  if [ -z ${_SUB_SITE} ]; then

    raise RequiredParameterNotFound "[site_configuration_get_subsite_languages] Please provide a valid site"

  fi

  if [ -z ${_SUBSCRIPTION} ]; then

    raise RequiredParameterNotFound "[site_configuration_get_subsite_languages] Please provide a valid subscription"

  fi

  local _CHECK_LANGUAGES_IN_SITE=$(printf "_%s_%s_LANGUAGES[@]" ${_SUBSCRIPTION^^} ${_SUB_SITE^^})
  local _CHECK_SIZE_LANGUAGES_IN_SITE="$(echo ${!_CHECK_LANGUAGES_IN_SITE:-} |wc -w)"

  if [ ${_CHECK_SIZE_LANGUAGES_IN_SITE} -gt 0 ]; then

    local _CHECK_LANGUAGES_IN_SITE=("${!_CHECK_LANGUAGES_IN_SITE}")

    if [ ${#_CHECK_LANGUAGES_IN_SITE[@]} -ge 1 ]; then

      # Prevent duplicates as it might be generated by *_dev.yml files
      echo ${_CHECK_LANGUAGES_IN_SITE[@]}  | tr ' ' '\n' | sort -u | tr '\n' ' '

    fi

  fi

}

# Get primary domains from subsite, pass language as parameter for multilanguage
function site_configuration_get_subsite_domains_by_env() {

  local _SUBSITE=${1:-}
  local _SUBSCRIPTION=${2:-}
  local _DOMAIN_ENVIRONMENT=${3:-}
  local _SITE_LANGUAGE=${4:-}

  if [ -z ${_SUBSITE} ]; then

    raise RequiredParameterNotFound "[site_configuration_get_subsite_domains_by_env] Please provide a valid site"

  fi

  if [ -z ${_SUBSCRIPTION} ]; then

    raise RequiredParameterNotFound "[site_configuration_get_subsite_domains_by_env] Please provide a valid subscription"

  fi

  if [ -z ${_DOMAIN_ENVIRONMENT} ]; then

    raise RequiredParameterNotFound "[site_configuration_get_subsite_domains_by_env] Please provide a valid environment"

  fi

  local _DOMAIN_LIST=""

  if [ -z ${_SITE_LANGUAGE} ]; then

    _DOMAIN_LIST=$(printf "_%s_%s_DOMAINS_%s[@]" ${_SUBSCRIPTION^^} ${_SUBSITE^^} ${_DOMAIN_ENVIRONMENT^^})

  else

    _DOMAIN_LIST=$(printf "_%s_%s_DOMAINS_%s_%s[@]" ${_SUBSCRIPTION^^} ${_SUBSITE^^} ${_DOMAIN_ENVIRONMENT^^} ${_SITE_LANGUAGE^^})

  fi

  _DOMAIN_LIST="$(echo ${!_DOMAIN_LIST:-})"

  # Prevent duplicates as it might be generated by *_dev.yml files
  echo ${_DOMAIN_LIST} | tr ' ' '\n' | sort -u | tr '\n' ' '

}

# Get all domains from subscription
function site_configuration_get_subscription_domains() {

  local _SUBSCRIPTION=${1:-}
  local _ENV=${2:-}
  local _DOMAIN_LIST=""

  if [ -z ${_SUBSCRIPTION} ]; then

    raise RequiredParameterNotFound "[site_configuration_get_subscription_domains] Please provide a valid subscription"

  fi

  if [ -z ${_ENV} ]; then

    raise RequiredParameterNotFound "[site_configuration_get_subscription_domains] Please provide a valid environment"

  fi

  local _SUBSITE_LIST=$(subscription_configuration_get_sites ${_SUBSCRIPTION})

  if [ ${_ENV} == "qa" ]; then

    for _SUB_SITE in ${_SUBSITE_LIST}; do

      local _SUBSITE_DOMAINS_LIST=$(site_configuration_get_subsite_qa_domains ${_SUB_SITE} ${_SUBSCRIPTION})
      _DOMAIN_LIST="${_DOMAIN_LIST} ${_SUBSITE_DOMAINS_LIST}"

    done

  else

    local _DOMAIN_LIST=$(site_configuration_get_domains ${_SUBSCRIPTION} "local" ${_SUBSITE_LIST})

  fi

  # Check exists domains
  local _CHECK_SIZE_DOMAINS="$(echo ${_DOMAIN_LIST:-} |wc -w)"

  if [ ${_CHECK_SIZE_DOMAINS} -gt 0 ]; then

    local _DOMAIN_LIST=("${_DOMAIN_LIST}")

    if [ ${#_DOMAIN_LIST[@]} -ge 1 ]; then

      echo ${_DOMAIN_LIST[@]}

    fi

  fi

}

#Get master repository url
function site_configuration_get_master() {

  local _SUB_SITE=${1:-}
  local _SUBSCRIPTION=${2:-}

  if [ -z ${_SUB_SITE} ]; then

    raise RequiredParameterNotFound "[site_configuration_get_master_repo_url] Please provide a valid site"

  fi

  if [ -z ${_SUBSCRIPTION} ]; then

    raise RequiredParameterNotFound "[site_configuration_get_master_repo_url] Please provide a valid subscription"

  fi

  local _MASTER_REPO_URL=$(printf "_%s_%s_MASTER" ${_SUBSCRIPTION^^} ${_SUB_SITE^^})
  if [ ! -z ${!_MASTER_REPO_URL:-} ]; then

    echo ${!_MASTER_REPO_URL}

  fi

}

#Get master repository url
function site_configuration_get_master_repo_url() {

  local _MASTER=${1:-}
  local _SUBSCRIPTION=${2:-}

  if [ -z ${_MASTER} ]; then

    raise RequiredParameterNotFound "[site_configuration_get_master_repo_url] Please provide a valid subscription"

  fi

  if [ -z ${_SUBSCRIPTION} ]; then

    raise RequiredParameterNotFound "[site_configuration_get_master_repo_url] Please provide a valid subscription"

  fi

  local _MASTER_REPO_URL=$(printf "_%s_%s_GIT" ${_SUBSCRIPTION^^} ${_MASTER^^})
  if [ ! -z ${!_MASTER_REPO_URL:-} ]; then

    echo ${!_MASTER_REPO_URL}

  fi

}

#Get real languages
function site_configuration_get_real_language() {

  local _LANGUAGE_CODE=${1:-}

  if [ -z ${_LANGUAGE_CODE} ]; then

    raise RequiredParameterNotFound "[site_configuration_get_language] Please provide a valid language code"

  fi
  local _CLEAR_CACHE_YML_LANGUAGE="${SF_SCRIPTS_HOME}/config/languages.yml"

  if [ ! -f "${_CLEAR_CACHE_YML_LANGUAGE}" ]; then

    raise FileNotFound "[clear_cache_load_configurations] File ${_CLEAR_CACHE_YML_LANGUAGE} not found!"

  else

    eval $(yml_loader ${_CLEAR_CACHE_YML_LANGUAGE} "_")
    #	yml_loader ${_CLEAR_CACHE_YML_LANGUAGE} "_"

  fi


  local _CHECK_LANGUAGE_CODE=$(printf "_LANGUAGES_%s[@]" ${_LANGUAGE_CODE^^})
  local _CHECK_LANGUAGE_SIZE="$(echo ${!_CHECK_LANGUAGE_CODE:-} |wc -w)"

  if [ ${_CHECK_LANGUAGE_SIZE} -gt 0 ]; then

    local _CHECK_LANGUAGE_CODE=("${_CHECK_LANGUAGE_CODE}")

    if [ ${#_CHECK_LANGUAGE_CODE[@]} -ge 1 ]; then

      echo ${!_CHECK_LANGUAGE_CODE}

    fi

  fi

}
