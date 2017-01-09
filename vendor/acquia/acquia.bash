#!/usr/bin/env bash

import git drush

function acquia_subsite_mysqldump_no_cache() {

  local _SUBSCRIPTION=${1:-}
  local _ENVIRONMENT=${2:-}
  local _SUB_SITE=${3:-}
  local _DOWNLOADED_DB_FILE=${4:-}

  local _SITE_PATH="/var/www/html/${_SUBSCRIPTION}.${_ENVIRONMENT}/docroot/sites/${_SUB_SITE}"

  ${_DRUSH} @${_SUBSCRIPTION}.${_ENVIRONMENT} ssh "cd ${_SITE_PATH} \
    && export _SUB_SITE=${_SUB_SITE} \
    && bash -s"  << "EOSSH"
  _CONN=$(drush sql-connect | sed "s/mysql/mysqldump/g")
  if [ $? -eq 0 ]; then

    _TABLES="/tmp/tables.txt"
    _SQL_FILE="/tmp/${_SUB_SITE}.sql"
    _SQL_FILE_GZ="/tmp/${_SUB_SITE}.sql.gz"

    echo -e "\n\e[32;1m[ ✔ ] Check and clear old files\e[m"
    [ -f ${_SQL_FILE} ] && rm ${_SQL_FILE}
    [ -f ${_SQL_FILE_GZ} ] && rm ${_SQL_FILE_GZ}
    _MYSQLDUMP=$(echo ${_CONN}| sed "s/--database=//g")
    _DB_NAME=$(echo $_CONN |cut -d" " -f2|sed "s/--database=//")

    echo -e "\e[32;1m[ ✔ ] Generate tables file in : ${_TABLES}\e[m"
    drush sqlq "use information_schema; SELECT table_name FROM tables WHERE table_schema = '${_DB_NAME}' \
    AND table_name NOT LIKE 'cache%' AND table_name <> 'flood' AND table_name <> 'semaphore' AND \
    table_name <>  'sessions' AND table_name <> 'watchdog';"> ${_TABLES}

    [ -f ${_TABLES} ] && sed -i "/table_name/d" ${_TABLES}

    echo -e "\e[32;1m[ ✔ ] Execute sql dump Schema\e[m"
    ${_MYSQLDUMP} --no-data > ${_SQL_FILE}

    echo -e "\e[32;1m[ ✔ ] Execute sql dump no create Schema\e[m"
    [ -f ${_TABLES} ] && ${_MYSQLDUMP} --no-create-info --tables $(cat ${_TABLES}) >> ${_SQL_FILE}


    [ -f ${_SQL_FILE} ] && echo -e "\e[32;1m[ ✔ ] Compressing file sql file\e[m" && gzip -9 ${_SQL_FILE}
    [ -f ${_TABLES} ] && rm ${_TABLES}

  else

    echo -e "\n\e[31;1m[ ✘ ] Problems\e[m"

  fi

EOSSH

  _SUBS_SQL_FILE="/tmp/${_SUB_SITE}.sql.gz"

  [ -f "${_DOWNLOADED_DB_FILE}" ] && rm ${_DOWNLOADED_DB_FILE}

  ${_DRUSH} -y rsync @${_SUBSCRIPTION}.${_ENVIRONMENT}:${_SUBS_SQL_FILE} ${_DOWNLOADED_DB_FILE}
  out_check_status $? "Imported SQL file with success in: [ ${_DOWNLOADED_DB_FILE} ]" "Failed import SQL file"

  out_info "Clean trash on ${_SUBSCRIPTION}.${_ENVIRONMENT}: ${_SUBS_SQL_FILE}" 1
  ${_DRUSH} @${_SUBSCRIPTION}.${_ENVIRONMENT} ssh \
    "rm ${_SUBS_SQL_FILE}";
  out_check_status $? "Cleared success" "Failed on clean"

}

function acquia_get_info_from_ac() {

  [ ! ${#} -eq 4 ] && raise RequiredParameterNotFound "[acquia_get_repository_url] Missing required parameters subscription, environment, command and/or parameter"
  local _ACQUIA_SUBSCRIPTION=${1:-}
  local _ACQUIA_ENVIRONMENT=${2:-}
  local _ACQUIA_COMMAND=${3:-}
  local _ACQUIA_PARAM=${4:-}

  local _CACHE_FILE="${_SF_STATIC_CACHE_BASE_FOLDER}/${_TASK_NAME}/${FUNCNAME}/${_ACQUIA_SUBSCRIPTION}_${_ACQUIA_ENVIRONMENT}_${_ACQUIA_COMMAND}_${_ACQUIA_PARAM}.cache"

  if [ -f ${_CACHE_FILE} ]; then

    cat ${_CACHE_FILE}
    return 0

  else

    filesystem_create_file ${_CACHE_FILE}

  fi

  local _ACQUIA_OUTPUT=$(drush_command @${_ACQUIA_SUBSCRIPTION}.${_ACQUIA_ENVIRONMENT} ${_ACQUIA_COMMAND} --format=json)

  _ACQUIA_PARAM_VAL="$(echo ${_ACQUIA_OUTPUT} | sed "s/},/\n/g" | sed "s/.*\"${_ACQUIA_PARAM}\":\s*\"\([^\"]*\)\".*/\1/")"
  echo ${_ACQUIA_PARAM_VAL} | tee ${_CACHE_FILE}

}

function acquia_get_repository_url() {

  [ ! ${#} -eq 2 ] && raise RequiredParameterNotFound "[acquia_get_repository_url] Missing required parameters subscription and/or environment"
  local _ACQUIA_SUBSCRIPTION=${1:-}
  local _ACQUIA_ENVIRONMENT=${2:-}

  local _ACQUIA_REPO_URL=$(acquia_get_info_from_ac ${_ACQUIA_SUBSCRIPTION} ${_ACQUIA_ENVIRONMENT} ac-site-info vcs_url)

  echo ${_ACQUIA_REPO_URL}

}

function acquia_get_repository_active_resource() {

  [ ! ${#} -eq 2 ] && raise RequiredParameterNotFound "[acquia_get_repository_url] Missing required parameters subscription and/or environment"
  local _ACQUIA_SUBSCRIPTION=${1:-}
  local _ACQUIA_ENVIRONMENT=${2:-}

  local _ACQUIA_REPO_RESOURCE=$(acquia_get_info_from_ac ${_ACQUIA_SUBSCRIPTION} ${_ACQUIA_ENVIRONMENT} ac-environment-info vcs_path)

  # Removing the "tags/" string from the resource
  echo ${_ACQUIA_REPO_RESOURCE} | sed 's#^tags\\/##g' | sed 's/[\]//g'

}

function acquia_clear_all_caches() {

  local _ACQUIA_SUBSCRIPTION=${1:-}
  local _ACQUIA_ENVIRONMENT=${2:-}
  local _ACQUIA_SUBSITE=${3:-}

  if [ -z ${_ACQUIA_SUBSCRIPTION} ]; then

    raise RequiredParameterNotFound "[acquia_clear_all_caches] Please provide a valid subscription"

  fi

  if [ -z ${_ACQUIA_ENVIRONMENT} ]; then

    raise RequiredParameterNotFound "[acquia_clear_all_caches] Please provide a valid environment"

  fi

  if [ -z ${_ACQUIA_SUBSITE} ]; then

    raise RequiredParameterNotFound "[acquia_clear_all_caches] Please provide a valid subsite"

  fi

  acquia_clear_drupal_cache ${_ACQUIA_SUBSCRIPTION} ${_ACQUIA_ENVIRONMENT} ${_ACQUIA_SUBSITE}
  acquia_clear_memcache ${_ACQUIA_SUBSCRIPTION} ${_ACQUIA_ENVIRONMENT}
  acquia_clear_varnish ${_ACQUIA_SUBSCRIPTION} ${_ACQUIA_ENVIRONMENT} ${_ACQUIA_SUBSITE}

}

function acquia_clear_drupal_cache() {

  local _ACQUIA_SUBSCRIPTION=${1:-}
  local _ACQUIA_ENVIRONMENT=${2:-}
  local _ACQUIA_SUBSITE=${3:-}

  if [ -z ${_ACQUIA_SUBSCRIPTION} ]; then

    raise RequiredParameterNotFound "[acquia_clear_drupal_cache] Please provide a valid subscription"

  fi

  if [ -z ${_ACQUIA_ENVIRONMENT} ]; then

    raise RequiredParameterNotFound "[acquia_clear_drupal_cache] Please provide a valid environment"

  fi

  if [ -z ${_ACQUIA_SUBSITE} ]; then

    raise RequiredParameterNotFound "[acquia_clear_drupal_cache] Please provide a valid subsite"

  fi

  local _ACQUIA_DOMAIN_LIST=$(site_configuration_get_domains ${_ACQUIA_SUBSCRIPTION} ${_ACQUIA_ENVIRONMENT} ${_ACQUIA_SUBSITE})
  local _ACQUIA_DRUSH_SUB_DOT_ENV="${_DRUSH} @${_ACQUIA_SUBSCRIPTION}.${_ACQUIA_ENVIRONMENT}"

  local _DOMAIN=$(echo "${_ACQUIA_DOMAIN_LIST}" | ${_SED} -e "s/\s/\n/g" | ${_GREP} "^con\|^www" | head -1)
  if [[ ${_ACQUIA_SUBSCRIPTION} == "osops" ]]; then

    local _DOMAIN=$(echo "${_ACQUIA_DOMAIN_LIST}" | ${_SED} -e "s/\s/\n/g" | head -1)

  fi

  if [ -z ${_DOMAIN} ]; then

    out_danger "Domain not found, please check the file ${_ACQUIA_SUBSCRIPTION}.yml" 1

  else

    out_info "Clearing Drupal cache for subscription ${_ACQUIA_SUBSCRIPTION} in ${_ACQUIA_ENVIRONMENT} environment"

    ${_ACQUIA_DRUSH_SUB_DOT_ENV} -l ${_DOMAIN} cc all
    out_check_status $? "Drupal cache cleared for ${_DOMAIN}!" "Drupal cache clear failed" 1

  fi

}

function acquia_clear_memcache() {

  local _ACQUIA_SUBSCRIPTION=${1:-}
  local _ACQUIA_ENVIRONMENT=${2:-}

  if [ -z ${_ACQUIA_SUBSCRIPTION} ]; then

    raise RequiredParameterNotFound "[acquia_clear_memcache] Please provide a valid subscription"

  fi

  if [ -z ${_ACQUIA_ENVIRONMENT} ]; then

    raise RequiredParameterNotFound "[acquia_clear_memcache] Please provide a valid environment"

  fi

  out_info "Clearing Memcache for subscription ${_ACQUIA_SUBSCRIPTION} in ${_ACQUIA_ENVIRONMENT} environment"

  local _ACQUIA_DRUSH_SUB_DOT_ENV="${_DRUSH} @${_ACQUIA_SUBSCRIPTION}.${_ACQUIA_ENVIRONMENT}"
  local _ACQUIA_WEB_SERVERS=$(${_ACQUIA_DRUSH_SUB_DOT_ENV} ac-server-list | grep "name" | cut -d: -f2 | grep -E "web-|staging-|ded-")

  for _WEB_SERVER in ${_ACQUIA_WEB_SERVERS}; do

    ${_ACQUIA_DRUSH_SUB_DOT_ENV} ssh "$(printf "/bin/echo -e 'flush_all\nquit' | nc -q1 %s.prod.hosting.acquia.com 11211" ${_WEB_SERVER})"
    out_check_status $? "Memcache clear for ${_WEB_SERVER} is successfully!" "Memcache clear for ${_WEB_SERVER} failed" 1

  done

}

function acquia_clear_varnish() {

  local _ACQUIA_SUBSCRIPTION=${1:-}
  local _ACQUIA_ENVIRONMENT=${2:-}
  local _ACQUIA_SUBSITE=${3:-}

  if [ -z ${_ACQUIA_SUBSCRIPTION} ]; then

    raise RequiredParameterNotFound "[acquia_clear_varnish] Please provide a valid subscription"

  fi

  if [ -z ${_ACQUIA_ENVIRONMENT} ]; then

    raise RequiredParameterNotFound "[acquia_clear_varnish] Please provide a valid environment"

  fi

  if [ -z ${_ACQUIA_SUBSITE} ]; then

    raise RequiredParameterNotFound "[acquia_clear_varnish] Please provide a valid subsite"

  fi

  local _ACQUIA_DOMAIN_LIST=$(site_configuration_get_domains ${_ACQUIA_SUBSCRIPTION} ${_ACQUIA_ENVIRONMENT} ${_ACQUIA_SUBSITE})
  local _ACQUIA_DRUSH_SUB_DOT_ENV="${_DRUSH} @${_ACQUIA_SUBSCRIPTION}.${_ACQUIA_ENVIRONMENT}"

  if [[ -z ${_ACQUIA_DOMAIN_LIST} ]]; then

    out_danger "Domains not found, please check the file ${_ACQUIA_SUBSCRIPTION}.yml" 1

  else

    for _DOMAIN in ${_ACQUIA_DOMAIN_LIST}; do

      out_info "Clearing Varnish cache for ${_DOMAIN}" 1

      ${_ACQUIA_DRUSH_SUB_DOT_ENV} ac-domain-purge ${_DOMAIN}
      out_check_status $? "Varnish cache clear for ${_DOMAIN} is successfully!" "Varnish cache clear for ${_DOMAIN} failed" 1

    done

  fi

}

function acquia_clear_varnish_for_alternative_domain() {

  local _ACQUIA_SUBSCRIPTION=${1:-}
  local _ACQUIA_ENVIRONMENT=${2:-}
  shift 2
  local _ACQUIA_DOMAINS=${@}

  if [ -z ${_ACQUIA_SUBSCRIPTION} ]; then

    raise RequiredParameterNotFound "[acquia_clear_varnish] Please provide a valid subscription"

  fi

  if [ -z ${_ACQUIA_ENVIRONMENT} ]; then

    raise RequiredParameterNotFound "[acquia_clear_varnish] Please provide a valid environment"

  fi

  if [[ -z ${_ACQUIA_DOMAINS} ]]; then

    raise RequiredParameterNotFound "[acquia_clear_varnish] Please provide a valid domain list"

  fi

  local _ACQUIA_DRUSH_SUB_DOT_ENV="${_DRUSH} @${_ACQUIA_SUBSCRIPTION}.${_ACQUIA_ENVIRONMENT}"

  for _DOMAIN in ${_ACQUIA_DOMAINS}; do

    out_info "Clearing Varnish cache for ${_DOMAIN}" 1
    ${_ACQUIA_DRUSH_SUB_DOT_ENV} ac-domain-purge ${_DOMAIN}
    out_check_status $? "Varnish cache clear for ${_DOMAIN} is successfully!" "Varnish cache clear for ${_DOMAIN} failed" 1

  done

}

function acquia_domain_list() {

  local _ACQUIA_SUBSCRIPTION=${1:-}
  local _ACQUIA_ENVIRONMENT=${2:-}

  if [ -z ${_ACQUIA_SUBSCRIPTION} ]; then

    raise RequiredParameterNotFound "[acquia_domain_list] Please provide a valid subscription"

  fi

  if [ -z ${_ACQUIA_ENVIRONMENT} ]; then

    raise RequiredParameterNotFound "[acquia_domain_list] Please provide a valid environemnt"

  fi

  local _ACQUIA_DOMAIN_LIST=$(${_DRUSH} @${_ACQUIA_SUBSCRIPTION}.${_ACQUIA_ENVIRONMENT} ac-domain-list | sed 's/ *name *: *//g')

  echo "${_ACQUIA_DOMAIN_LIST}"

}

function acquia_code_deploy() {

  local _ACQUIA_SUBSCRIPTION=${1:-}
  local _ACQUIA_ENVIRONMENT=${2:-}
  local _ACQUIA_RESOURCE=${3:-}

  if [ -z ${_ACQUIA_SUBSCRIPTION} ]; then

    raise RequiredParameterNotFound "[acquia_code_deploy] Please provide a valid subscription"

  fi

  if [ -z ${_ACQUIA_ENVIRONMENT} ]; then

    raise RequiredParameterNotFound "[acquia_code_deploy] Please provide a valid environment"

  fi

  if [[ -z ${_ACQUIA_RESOURCE} ]]; then

    raise RequiredParameterNotFound "[acquia_code_deploy] Please provide a valid resource"

  fi

  local _ACQUIA_DRUSH_SUB_DOT_ENV="${_DRUSH} @${_ACQUIA_SUBSCRIPTION}.${_ACQUIA_ENVIRONMENT}"

  local	_ACQUIA_TASK_DEPLOY=$(${_ACQUIA_DRUSH_SUB_DOT_ENV} ac-code-path-deploy tags/${_ACQUIA_RESOURCE} --format=json)
  [[ $? -ge 1 ]] && return 1;

  local _TASK_ID="$(echo ${_ACQUIA_TASK_DEPLOY} | jq -r '.id')"
  acquia_task_monitor ${_ACQUIA_SUBSCRIPTION} ${_ACQUIA_ENVIRONMENT} ${_TASK_ID}
  out_check_status $? "Resource activated successfully" "Activing resource failed" 1

}

function acquia_database_backup() {

  local _ACQUIA_SUBSCRIPTION=${1:-}
  local _ACQUIA_ENVIRONMENT=${2:-}
  local _ACQUIA_DATABASE_SITE=${3:-}

  if [ -z ${_ACQUIA_SUBSCRIPTION} ]; then

    raise RequiredParameterNotFound "[acquia_database_backup] Please provide a valid subscription"

  fi

  if [ -z ${_ACQUIA_ENVIRONMENT} ]; then

    raise RequiredParameterNotFound "[acquia_database_backup] Please provide a valid environment"

  fi

  if [[ -z ${_ACQUIA_DATABASE_SITE} ]]; then

    raise RequiredParameterNotFound "[acquia_database_backup] Please provide a valid database site"

  fi

  local _ACQUIA_DRUSH_SUB_DOT_ENV="${_DRUSH} @${_ACQUIA_SUBSCRIPTION}.${_ACQUIA_ENVIRONMENT}"

  local	_ACQUIA_TASK_DEPLOY=$(${_ACQUIA_DRUSH_SUB_DOT_ENV} ac-database-instance-backup	${_ACQUIA_DATABASE_SITE} --format=json)
  [[ $? -ge 1 ]] && return 1;

  local _TASK_ID="$(echo ${_ACQUIA_TASK_DEPLOY} | jq -r '.id')"
  acquia_task_monitor ${_ACQUIA_SUBSCRIPTION} ${_ACQUIA_ENVIRONMENT} ${_TASK_ID}
  out_check_status $? "Backup generated successfully" "Backup generated failed" 1

}

function acquia_task_monitor() {

  local _ACQUIA_SUBSCRIPTION=${1:-}
  local _ACQUIA_ENVIRONMENT=${2:-}
  local _ACQUIA_TASK_ID=${3:-}
  local _OLD_LOG="null"
  local _STATE="null"
  local _COMPLETED="null"
  local _LOOP_ERROR=0

  if [ -z ${_ACQUIA_SUBSCRIPTION} ]; then

    raise RequiredParameterNotFound "[acquia_code_deploy] Please provide a valid subscription"

  fi

  if [ -z ${_ACQUIA_ENVIRONMENT} ]; then

    raise RequiredParameterNotFound "[acquia_code_deploy] Please provide a valid environment"

  fi

  local _ACQUIA_DRUSH_SUB_DOT_ENV="${_DRUSH} @${_ACQUIA_SUBSCRIPTION}.${_ACQUIA_ENVIRONMENT}"

  out_info "Monitoring task ${_ACQUIA_TASK_ID}" 1
  while [[ ${_COMPLETED} == "null" ]]; do

    local _TASK_INFO_RESULT="$(${_ACQUIA_DRUSH_SUB_DOT_ENV} ac-task-info ${_ACQUIA_TASK_ID} --format=json)"
    [[ $? -ge 1 ]] && return 0;

    if [[ $_TASK_INFO_RESULT != "null" ]]; then

      local _STATE="$(echo ${_TASK_INFO_RESULT} | jq -r '.state')"
      local _COMPLETED="$(echo ${_TASK_INFO_RESULT} | jq -r '.completed')"

      local _NEW_LOG="$(echo ${_TASK_INFO_RESULT} | jq -r '.logs')"
      local _DESCRIPTION="$(echo ${_TASK_INFO_RESULT} | jq -r '.description')"

      local _DIFF=${_NEW_LOG//"$_OLD_LOG"/}
      local _MGS=$(echo ${_DIFF}| sed -e "s|\n|\t\n|g")
      local _MGS=$(echo ${_DIFF}| awk '{print $1  $3}')

      if [[ ! -z ${_MGS} ]] || [[ ! -z ${_DESCRIPTION} ]] || [[ ${_MGS} != "" ]] || [[ ${_DESCRIPTION} != "" ]]; then

        echo -e "\t${IGREEN} ${_MGS} - ${_DESCRIPTION} ${COLOR_OFF}"

      else

        if [[ ${_STATE} != "null" ]] || [[ ${_DESCRIPTION} != "null" ]]; then

          echo -e "\t${IGREEN} [ ${_STATE} ] - ${_DESCRIPTION} ${COLOR_OFF}"

        fi

      fi

      local _OLD_LOG="${_NEW_LOG}"

    else

      _LOOP_ERROR=$(expr ${_LOOP_ERROR} + 1)
      out_warning "Try again in 8 seconds." 1
      sleep 8;

    fi

    if [[ ${_LOOP_ERROR} -eq 5 ]]; then

      return 0;

    fi
    # Checking consumes resources, so wait for 3 seconds between checks.
    sleep 8;

  done

  if [[ "${_STATE}" = "error" ]]; then

    echo -e "\t${BYELLOW} State:${COLOR_OFF} ${BRED}${_STATE}${COLOR_OFF}\n";
    return 1;

  fi

  echo -e "\t${BYELLOW} State:${COLOR_OFF} ${BGREEN}${_STATE}${COLOR_OFF}\n"

  return 0;

}

function acquia_install_global_module() {

  local _ACQUIA_SUBSCRIPTION=${1:-}
  local _ACQUIA_ENV=${2:-}
  local _ACQUIA_MODULE=${3:-}
  local _ACQUIA_MODULE_VERSION=${4:-}
  local _ACQUIA_MODULE_TEST_COMMAND=${5:-}

  out_info "Checking status of module [ ${_ACQUIA_MODULE} ]" 1

  ${_DRUSH} @${_ACQUIA_SUBSCRIPTION}.${_ACQUIA_ENV} ssh "export _ACQUIA_MODULE=${_ACQUIA_MODULE} \
    && export _ACQUIA_MODULE_VERSION=${_ACQUIA_MODULE_VERSION} \
    && export _ACQUIA_MODULE_TEST_COMMAND=${_ACQUIA_MODULE_TEST_COMMAND} \
    && bash -s" << "EOSSH"
    drush cc drush
    drush help ${_ACQUIA_MODULE_TEST_COMMAND} > /dev/null && true

    if [ $? -ge 1 ]; then

      echo -e "\e[31;1m[ ✘ ] Site Audit module not found. Downloading it.\e[m"
      drush dl ${_ACQUIA_MODULE}-${_ACQUIA_MODULE_VERSION}

    else

      echo -e "\e[32;1m[ ✔ ] Module [ ${_ACQUIA_MODULE} ] module is already downloaded\e[m"

    fi

EOSSH

}

function acquia_delete_remote_folder() {

  local _ACQUIA_SUBSCRIPTION=${1:-}
  local _ACQUIA_ENV=${2:-}
  local _ACQUIA_REMOTE_FOLDER=${3:-}

  ${_DRUSH} @${_ACQUIA_SUBSCRIPTION}.${_ACQUIA_ENV} ssh "export _ACQUIA_REMOTE_FOLDER=${_ACQUIA_REMOTE_FOLDER} \
    && bash -s" << "EOSSH"

    _ACQUIA_REMOTE_FOLDER_PARENT=$(dirname ${_ACQUIA_REMOTE_FOLDER})

    if [ -d ${_ACQUIA_REMOTE_FOLDER_PARENT} ]; then

      rm -rf ${_ACQUIA_REMOTE_FOLDER_PARENT}
      echo -e "\n\e[32;1m[ ✔ ] Cleared Site Audit folder in [ ${_ACQUIA_REMOTE_FOLDER_PARENT} ]\e[m"

    else

      echo -e "\n\e[31;1m[ ✘ ] [ ${_ACQUIA_REMOTE_FOLDER_PARENT} ] is not a valid folder\e[m"

    fi

EOSSH

}
