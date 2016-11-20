#!/usr/bin/env bash

function site_configuration_get_subsite_database_connection {
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

  local _DB_USER=$(site_configuration_get_subsite_database_user ${_SUBSCRIPTION} ${_SUB_SITE} ${_ENV})
  local _DB_PASS=$(site_configuration_get_subsite_database_password ${_SUBSCRIPTION} ${_SUB_SITE} ${_ENV})
  local _DB_SERVER=$(site_configuration_get_subsite_database_server ${_SUBSCRIPTION} ${_SUB_SITE} ${_ENV})
  local _DB_NAME=$(site_configuration_get_subsite_database_name ${_SUBSCRIPTION} ${_SUB_SITE} ${_ENV})

  if [ -z ${_DB_USER} ] && [ -z ${_DB_SERVER} ] && [ -z ${_DB_NAME} ]; then

    echo ""

  elif [ -z ${_DB_PASS} ]; then

    echo "-u${_DB_USER} -h${_DB_SERVER} ${_DB_NAME}"

  else

    echo "-u${_DB_USER} -p${_DB_PASS} -h${_DB_SERVER} ${_DB_NAME}"

  fi

}

# Check if site multilanguage domain
function site_configuration_is_subsite_multi_language() {

  local _SUB_SITE=${1:-}
  local _SUBSCRIPTION=${2:-}

  if [ -z ${_SUB_SITE} ]; then

    raise RequiredParameterNotFound "[site_configuration_is_subsite_multi_language] Please provide a valid site"

  fi

  if [ -z ${_SUBSCRIPTION} ]; then

    raise RequiredParameterNotFound "[site_configuration_is_subsite_multi_language] Please provide a valid subscription"

  fi

  local _LIST_SUBSITE_LANGUAGES=$(printf "_%s_%s_LANGUAGES" ${_SUBSCRIPTION^^} ${_SUB_SITE^^})
  local _CHECK_SIZE_SUB_SITE_LANGUAGES="$(echo ${!_LIST_SUBSITE_LANGUAGES:-} |wc -w)"

  if [ ${_CHECK_SIZE_SUB_SITE_LANGUAGES} -gt 0 ]; then

    return 0;

  else

    return 1;

  fi

}

# Get all domains from a single Subsite
function site_configuration_get_domains() {

  local _SUBSCRIPTION=${1:-}
  local _DOMAIN_ENVIRONMENT=${2:-}
  shift 2
  local _SUBSITE_LIST=${@}

  if [ -z ${_SUBSCRIPTION} ]; then

    raise RequiredParameterNotFound "[site_configuration_get_domains] Please provide a valid subscription"

  fi

  if [ -z ${_DOMAIN_ENVIRONMENT} ]; then

    raise RequiredParameterNotFound "[site_configuration_get_domains] Please provide a valid environment"

  fi

  if [[ -z ${_SUBSITE_LIST} ]]; then

    raise RequiredParameterNotFound "[site_configuration_get_domains] Please provide at least one site"

  fi

  local _ALL_DOMAINS=""

  for _SUBSITE in ${_SUBSITE_LIST}; do

    local _SUBSITE_LANGUAGE=$(site_configuration_get_subsite_languages ${_SUBSITE} ${_SUBSCRIPTION})
    local _DOMAIN_LIST=""

    if [[ -z ${_SUBSITE_LANGUAGE} ]]; then

      _DOMAIN_LIST=$(site_configuration_get_subsite_domains_by_env "${_SUBSITE}" "${_SUBSCRIPTION}" "${_DOMAIN_ENVIRONMENT}")

    else

      for _LANG in ${_SUBSITE_LANGUAGE}; do

        local _DOMAIN=$(site_configuration_get_subsite_domains_by_env "${_SUBSITE}" "${_SUBSCRIPTION}" "${_DOMAIN_ENVIRONMENT}" "${_LANG}")
        _DOMAIN_LIST="${_DOMAIN_LIST} ${_DOMAIN}"

      done

    fi

    _ALL_DOMAINS="${_ALL_DOMAINS} ${_DOMAIN_LIST}"

  done

  echo ${_ALL_DOMAINS}

}

function site_configuration_get_subsite_qa_domains() {

  local _SUB_SITE=${1:-}
  local _SUBSCRIPTION=${2:-}
  local _TARGET_LANGUAGE=${3:-}
  local _SUB_SITE_CONVERTED_NAME=$(echo ${_SUB_SITE} | sed "s/_/-/g")
  local _DOMAIN_LIST=""

  if (site_configuration_is_subsite_multi_language ${_SUB_SITE} ${_SUBSCRIPTION}); then

    _SUBSITE_LANGUAGE_LIST=$(site_configuration_get_subsite_languages ${_SUB_SITE} ${_SUBSCRIPTION})
    for _LANG in ${_SUBSITE_LANGUAGE_LIST}; do

      if [ -z "${_TARGET_LANGUAGE}" ] || [ "${_TARGET_LANGUAGE}" == "${_LANG}" ]; then

        local _SITE_CONFIGURATION_DNS=$(printf "www-%s-%s-%s-qa.citdev" ${_SUB_SITE_CONVERTED_NAME} ${_SUBSCRIPTION} ${_LANG})
        local _SITE_CONFIGURATION_EDIT_DNS=$(printf "edit-%s-%s-%s-qa.citdev" ${_SUB_SITE_CONVERTED_NAME} ${_SUBSCRIPTION} ${_LANG})
        _DOMAIN_LIST="${_DOMAIN_LIST} ${_SITE_CONFIGURATION_DNS} ${_SITE_CONFIGURATION_EDIT_DNS}"

      fi

    done

  else

    local _SITE_CONFIGURATION_DNS=$(printf "www-%s-%s-qa.citdev" ${_SUB_SITE_CONVERTED_NAME} ${_SUBSCRIPTION})
    local _SITE_CONFIGURATION_EDIT_DNS=$(printf "edit-%s-%s-qa.citdev" ${_SUB_SITE_CONVERTED_NAME} ${_SUBSCRIPTION})
    _DOMAIN_LIST="${_DOMAIN_LIST} ${_SITE_CONFIGURATION_DNS} ${_SITE_CONFIGURATION_EDIT_DNS}"

  fi

  echo ${_DOMAIN_LIST}

}

function site_configuration_set_configs() {

  local _SITE_CONFIGURATION_ENV=${1:-}
  local _SITE_CONFIGURATION_ENV_FILE="${SF_SCRIPTS_HOME}/modules/site_configuration/php_scripts/site_configuration.set_${_SITE_CONFIGURATION_ENV}.php"

  if [ ! -f ${_SITE_CONFIGURATION_ENV_FILE} ]; then

    raise FileNotFound "[site_configuration_set_configs] Missing configuration file ${_SITE_CONFIGURATION_ENV_FILE}"

  fi

  ${_DRUSH} scr ${_SITE_CONFIGURATION_ENV_FILE}

}

function site_configuration_configure_database_to_developer() {

  if [ -z ${1:-} ] && [ -d ${1} ] ; then

    raise RequiredFolderNotFound "[site_configuration_configure_database_to_developer] Please provide a valid folder"

  else

    local _SUBSITE_FOLDER=${1}

  fi

  if [ -d ${_SUBSITE_FOLDER} ]; then

    ${_CD} ${_SUBSITE_FOLDER}

    drush_command vset file_temporary_path /tmp
    drush_command vset file_private_path /tmp
    drush_command vset autologout_enforce_admin 0
    drush_command vset autologout_timeout 10000
    drush_command vset autologout_padding 10000
    drush_command vset page_cache_maximum_age 0
    drush_command vset cache_lifetime 0
    drush_command vset cache 0
    drush_command vset block_cache 0
    drush_command vset page_compression 0
    drush_command vset preprocess_css 0
    drush_command vset preprocess_js 0
    drush_command vset error_level 2
    drush_command en -y autologout dblog
    drush_command dis -y memcache memcache_admin syslog

  fi

}

function site_configuration_files_download() {

  if [ -z ${1:-} ]; then

    raise RequiredFolderNotFound "[site_configuration_files_download] Please provide a valid subscription"

  else

    local _SITE_CONFIGURATION_FILES_SUBSCRIPTION=${1}

  fi

  if [ -z ${2:-} ]; then

    raise RequiredFolderNotFound "[site_configuration_files_download] Please provide a valid environment"

  else

    local _SITE_CONFIGURATION_FILES_ENVIRONMENT=${2}

  fi

  if [ -z ${3:-} ]; then

    raise RequiredFolderNotFound "[site_configuration_files_download] Please provide a valid subsite"

  else

    local _SITE_CONFIGURATION_FILES_SUBITSITE=${3}

  fi

  if [ -z ${4:-} ]; then

    raise RequiredFolderNotFound "[site_configuration_files_download] Please provide a valid folder"

  else

    local _SITE_CONFIGURATION_FILES_LOCAL_PATH=${4}

  fi


  local _SITE_CONFIGURATION_FILES_FORCE_DOWNLOAD=""
  if [ ! -z ${5:-} ]; then

    local _SITE_CONFIGURATION_FILES_FORCE_DOWNLOAD=${5:-}

    if [ "${_SITE_CONFIGURATION_FILES_FORCE_DOWNLOAD}" == 1 ]; then

      _SITE_CONFIGURATION_FILES_FORCE_DOWNLOAD="-y"

    fi

    if [ "${_SITE_CONFIGURATION_FILES_FORCE_DOWNLOAD}" == "true" ]; then

      _SITE_CONFIGURATION_FILES_FORCE_DOWNLOAD="-y"

    fi

    if [ "${_SITE_CONFIGURATION_FILES_FORCE_DOWNLOAD}" == "y" ]; then

      _SITE_CONFIGURATION_FILES_FORCE_DOWNLOAD="-y"

    fi

  fi

  if [ -L ${_SITE_CONFIGURATION_FILES_LOCAL_PATH} ]; then

    out_warning "Removing old link ${_SITE_CONFIGURATION_FILES_LOCAL_PATH}"
    ${_UNLINK} ${_SITE_CONFIGURATION_FILES_LOCAL_PATH}

  fi

  filesystem_create_folder_777 ${_SITE_CONFIGURATION_FILES_LOCAL_PATH}

  if [ ! -d ${_SITE_CONFIGURATION_FILES_LOCAL_PATH} ]; then

    raise FolderNotFound "Folder not found: ${_SITE_CONFIGURATION_FILES_LOCAL_PATH}"

  fi

  local _REMOTE_PATH="@${_SITE_CONFIGURATION_FILES_SUBSCRIPTION}.${_SITE_CONFIGURATION_FILES_ENVIRONMENT}:/mnt/gfs/${_SITE_CONFIGURATION_FILES_SUBSCRIPTION}.${_SITE_CONFIGURATION_FILES_ENVIRONMENT}/sites/${_SITE_CONFIGURATION_FILES_SUBITSITE}/files/"

  out_info "Downloading files from @${_SITE_CONFIGURATION_FILES_SUBSCRIPTION}.${_SITE_CONFIGURATION_FILES_ENVIRONMENT}" 1
  drush_rsync ${_REMOTE_PATH} ${_SITE_CONFIGURATION_FILES_LOCAL_PATH} ${_SITE_CONFIGURATION_FILES_FORCE_DOWNLOAD}
  out_check_status $? "Download to directory [ ${_SITE_CONFIGURATION_FILES_LOCAL_PATH} ] successfully" "Failed download file: [ @${_SITE_CONFIGURATION_FILES_SUBSCRIPTION}.${_SITE_CONFIGURATION_FILES_ENVIRONMENT}:${_REMOTE_PATH} ]"
  ${_CHMOD} -R 777 "${_SITE_CONFIGURATION_FILES_LOCAL_PATH}"

}


function site_configuration_files_upload() {

  if [ -z ${1:-} ]; then

    raise RequiredFolderNotFound "[site_configuration_files_upload] Please provide a valid subscription"

  else

    local _SITE_CONFIGURATION_FILES_SUBSCRIPTION=${1}

  fi

  if [ -z ${2:-} ]; then

    raise RequiredFolderNotFound "[site_configuration_files_upload] Please provide a valid environment"

  else

    local _SITE_CONFIGURATION_FILES_ENVIRONMENT=${2}

  fi

  if [ -z ${3:-} ]; then

    raise RequiredFolderNotFound "[site_configuration_files_upload] Please provide a valid subsite"

  else

    local _SITE_CONFIGURATION_FILES_SUBITSITE=${3}

  fi

  if [ -z ${4:-} ]; then

    raise RequiredFolderNotFound "[site_configuration_files_upload] Please provide a valid folder"

  else

    local _SITE_CONFIGURATION_FILES_LOCAL_PATH=${4}

  fi


  local _SITE_CONFIGURATION_FILES_FORCE_DOWNLOAD=""
  if [ ! -z ${5:-} ]; then

    local _SITE_CONFIGURATION_FILES_FORCE_DOWNLOAD=${5:-}

    if [ "${_SITE_CONFIGURATION_FILES_FORCE_DOWNLOAD}" == 1 ]; then

      _SITE_CONFIGURATION_FILES_FORCE_DOWNLOAD="-y"

    fi

    if [ "${_SITE_CONFIGURATION_FILES_FORCE_DOWNLOAD}" == "true" ]; then

      _SITE_CONFIGURATION_FILES_FORCE_DOWNLOAD="-y"

    fi

    if [ "${_SITE_CONFIGURATION_FILES_FORCE_DOWNLOAD}" == "y" ]; then

      _SITE_CONFIGURATION_FILES_FORCE_DOWNLOAD="-y"

    fi

  fi

  if [ ! -d ${_SITE_CONFIGURATION_FILES_LOCAL_PATH} ]; then

    raise FolderNotFound "Folder not found: ${_SITE_CONFIGURATION_FILES_LOCAL_PATH}"

  fi
  local _REMOTE_PATH="@${_SITE_CONFIGURATION_FILES_SUBSCRIPTION}.${_SITE_CONFIGURATION_FILES_ENVIRONMENT}:/mnt/gfs/${_SITE_CONFIGURATION_FILES_SUBSCRIPTION}.${_SITE_CONFIGURATION_FILES_ENVIRONMENT}/sites/${_SITE_CONFIGURATION_FILES_SUBITSITE}/files/"

  out_info "Uploading files to @${_SITE_CONFIGURATION_FILES_SUBITSITE}.${_SITE_CONFIGURATION_FILES_ENVIRONMENT}"
  drush_rsync ${_SITE_CONFIGURATION_FILES_LOCAL_PATH} ${_REMOTE_PATH} ${_SITE_CONFIGURATION_FILES_FORCE_DOWNLOAD}
  out_check_status $? "Upload to directory [ ${_SITE_CONFIGURATION_FILES_LOCAL_PATH} ] successfully" "Failed upload file: [ ${_REMOTE_PATH} ]"

}


#Get master repository resource
function site_configuration_get_master_branch_by_env() {

	local _MASTER=${1:-}
	local _SUBSCRIPTION=${2:-}
	local _ENVIRONMENT=${3:-}

	if [ -z ${_MASTER} ]; then

    raise RequiredParameterNotFound "[site_configuration_get_master_branch_by_env] Please provide a valid site"

  fi

	if [ -z ${_SUBSCRIPTION} ]; then

		raise RequiredParameterNotFound "[site_configuration_get_master_branch_by_env] Please provide a valid subscription"

	fi

	if [ -z ${_ENVIRONMENT} ]; then

		raise RequiredParameterNotFound "[site_configuration_get_master_branch_by_env] Please provide a valid environment"

	fi

	local _MASTER_REPO_RESOURCE=$(printf "_%s_%s_%s" ${_SUBSCRIPTION^^} ${_MASTER^^} ${_ENVIRONMENT^^})
  if [ ! -z ${!_MASTER_REPO_RESOURCE:-} ]; then

		echo ${!_MASTER_REPO_RESOURCE}

	fi

}

function site_configuration_reindex() {

  local _SUBSCRIPTION=${1:-}
  local _ENV=${2:-}
  local _SUBSITE_REAL_NAME=${3:-}
  local _SUBSITE_DOMAIN=${4:-}
  shift 4
  local _RUN_REINDEX=${@}

  if [ -z ${_SUBSCRIPTION} ]; then

    raise RequiredParameterNotFound "[site_configuration_reindex] Please provide a valid subscription"

  fi

  if [ -z ${_ENV} ]; then

    raise RequiredParameterNotFound "[site_configuration_reindex] Please provide a valid environment"

  fi

  if [ -z ${_SUBSITE_REAL_NAME} ]; then

    raise RequiredParameterNotFound "[site_configuration_reindex] Please provide a valid subsite"

  fi

  if [ -z ${_SUBSITE_DOMAIN} ]; then

    raise RequiredParameterNotFound "[site_configuration_reindex] Please provide a valid domain"

  fi

  _SUB_DOT_ENV="${_SUBSCRIPTION}.${_ENV}"
  _SUBSITE_PATH="/var/www/html/${_SUB_DOT_ENV}/docroot/sites/${_SUBSITE_REAL_NAME}"
  _DRUSH_SUB_DOT_ENV="${_DRUSH} @${_SUB_DOT_ENV}"

  local _REINDEX_COMMAND="[ ! -d ${_SUBSITE_PATH} ] && echo -e '\n\e[31;1m[ ✘ ] Folder does not exist.\e[m\n' && exit; cd ${_SUBSITE_PATH} && drush cc drush"

  for _REINDEX in ${_RUN_REINDEX}; do

    local _REINDEX_FUNCTION="site_configuration_reindex_${_REINDEX}"

    if (is_function? "${_REINDEX_FUNCTION}"); then

      _REINDEX_COMMAND="${_REINDEX_COMMAND}; $(${_REINDEX_FUNCTION} ${_SUBSITE_DOMAIN})"

    fi

  done

  out_info "Clearing cache in [ ${_SUBSITE_PATH} ] on site [ ${_SUBSITE_DOMAIN} ]."

  local _REINDEX_COMMAND="${_REINDEX_COMMAND}; drush cron -l ${_SUBSITE_DOMAIN}; drush cc all"

  ${_DRUSH_SUB_DOT_ENV} ssh \
    "${_REINDEX_COMMAND}"
  out_check_status $? "Site reindexed with success" "Error on reindex"

}

function site_configuration_reindex_solr() {

  local _SUBSITE_DOMAIN=${1:-}

  local _SOLR_REINDEX="drush ev \"module_load_include('inc', 'apachesolr_multisitesearch', 'apachesolr_multisitesearch.admin');apachesolr_multisitesearch_refresh_metadata_now();\" \
    && drush solr-delete-index -l ${_SUBSITE_DOMAIN}
    && drush solr-mark-all -l ${_SUBSITE_DOMAIN}
    && drush solr-index -l ${_SUBSITE_DOMAIN}"

  echo ${_SOLR_REINDEX}

}

function site_configuration_reindex_bv() {

  local _BV_REINDEX="if [ \$(drush sqlq \"SELECT s.status as '' FROM system as s WHERE s.name = 'bv' AND s.type = 'module';\" |sed '/^$/d') == \"1\" ]; then \
      drush sqlq 'TRUNCATE bv_product_statistics';
      drush sqlq 'TRUNCATE cache_bv';
      drush sqlq 'TRUNCATE cache_entity_node';
    else
      echo -e '\n\e[31;1m[ ✘ ] Bv is not enabled.\e[m\n';
    fi"

  echo ${_BV_REINDEX}

}

function site_configuration_reindex_sitemap() {

  local _SUBSITE_DOMAIN=${1:-}

  local _SITEMAP_REINDEX="drush vdel -y xmlsitemap_base_url \
    && drush xmlsitemap-rebuild -l ${_SUBSITE_DOMAIN}"

  echo ${_SITEMAP_REINDEX}

}

function site_configuration_get_base_name_from_folder() {

  local _SUB_SITE_FOLDER_NAME_PARAM=${1:-}
  local _SITE_CONFIGURATION_SUBSCRIPTION=${2:-}
  local _CACHE_FILE="${_SF_STATIC_CACHE_BASE_FOLDER}/${_TASK_NAME}/${FUNCNAME}/${_SUB_SITE_FOLDER_NAME_PARAM}.cache"

  if [ -f ${_CACHE_FILE} ]; then

    cat ${_CACHE_FILE}
    return 0

  else

    filesystem_create_file ${_CACHE_FILE}

  fi

  local _SUB_SITES=$(subscription_configuration_get_sites ${_SITE_CONFIGURATION_SUBSCRIPTION})

  for _SUB_SITE in ${_SUB_SITES}; do

    local _SUB_SITE_FOLDER_NAME=$(site_configuration_get_subsite_name ${_SUB_SITE} ${_SITE_CONFIGURATION_SUBSCRIPTION})

    if [[ "${_SUB_SITE_FOLDER_NAME_PARAM}" == "${_SUB_SITE_FOLDER_NAME}" ]]; then

      echo ${_SUB_SITE} | tee ${_CACHE_FILE}
      return 0

    fi

  done

}
