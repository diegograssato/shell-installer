#!/usr/bin/env bash

function local_setup_configuration_sites_php() {

  out_info "Configuring sites.local.php for ${_LOCAL_SETUP_SUBSCRIPTION}" 1

  local _SETTINGS_SUBSCRIPTION_CONFIG="${_LOCAL_SETUP_SUBSCRIPTION_WEB_SITE_REAL_PATH}/sites.local.php"

  cat <<EOF | tee ${_SETTINGS_SUBSCRIPTION_CONFIG} > /dev/null
<?php
EOF

	# Generate site.local.php all subsites

  for _SUBSCRIPTION in ${_LOCAL_SETUP_SUBSCRIPTION_SAME_VERSION}; do

    local _SUBSITE_LIST=$(subscription_configuration_get_sites ${_SUBSCRIPTION})

    for _SUB in ${_SUBSITE_LIST}; do

      local _SETTINGS_CONFIGURATION_GET_SUBSITE_NAME=$(site_configuration_get_subsite_name ${_SUB} ${_SUBSCRIPTION})

      local _DOMAIN_LIST=$(site_configuration_get_domains ${_SUBSCRIPTION} "local" ${_SUB})

      for _DOMAIN in ${_DOMAIN_LIST}; do

        cat <<EOF | tee -a ${_SETTINGS_SUBSCRIPTION_CONFIG}  > /dev/null 2>&1
\$sites['${_DOMAIN}'] = '${_SETTINGS_CONFIGURATION_GET_SUBSITE_NAME}';
EOF

      done

    done

  done

	if [ -f "${_SETTINGS_SUBSCRIPTION_CONFIG}" ]; then

		out_success "Created file ${_SETTINGS_SUBSCRIPTION_CONFIG}"

	else

		out_danger "File ${_SETTINGS_SUBSCRIPTION_CONFIG} not found!"

	fi

}

function local_setup_configuration_settings_php() {

  out_info "Configuring settings.local.php for ${_LOCAL_SETUP_SUBSITE}" 1
  local _SETTINGS_SITE_CONFIG="${_LOCAL_SETUP_SUBSCRIPTION_WEB_SITE_REAL_PATH}/${_LOCAL_SETUP_SUBSITE_REAL_NAME}/settings.local.php"

  # Get database settings
  local _DATABASE_LOCAL_USER=$(site_configuration_get_subsite_database_user ${_LOCAL_SETUP_SUBSITE} ${_LOCAL_SETUP_SUBSCRIPTION} ${_LOCAL_SETUP_DB_DST})
  local _DATABASE_LOCAL_PASSWORD=$(site_configuration_get_subsite_database_password ${_LOCAL_SETUP_SUBSITE} ${_LOCAL_SETUP_SUBSCRIPTION} ${_LOCAL_SETUP_DB_DST})
  local _DATABASE_LOCAL_HOST=${_LOCAL_SETUP_DATABASE_DOCKER_CONTAINER}
  local _DATABASE_LOCAL_DATABASE=$(site_configuration_get_subsite_database_name ${_LOCAL_SETUP_SUBSITE} ${_LOCAL_SETUP_SUBSCRIPTION} ${_LOCAL_SETUP_DB_DST})

  if [[ ! ${_LOCAL_SETUP_DB_TYPE} == ${_LOCAL_SETUP_PARAMETER_DB_LOCAL} ]]; then

    local _DATABASE_LOCAL_HOST=$(site_configuration_get_subsite_database_server ${_LOCAL_SETUP_SUBSITE} ${_LOCAL_SETUP_SUBSCRIPTION} ${_LOCAL_SETUP_DB_DST})

  fi

  if [ -z "${_DATABASE_LOCAL_USER}" ] || [ -z "${_DATABASE_LOCAL_HOST}" ] || [ -z "${_DATABASE_LOCAL_DATABASE}" ]; then

    raise MissingQaDbSettings "[local_setup_configuration_settings_php] Please make sure the ${_LOCAL_SETUP_DB_DST} database settings is configured in the yml file."

  fi

  cat <<EOF | tee ${_SETTINGS_SITE_CONFIG} > /dev/null 2>&1
<?php

# Database session
\$databases['default']['default'] = array(
  'driver' => 'mysql',
  'database' => '${_DATABASE_LOCAL_DATABASE}',
  'username' => '${_DATABASE_LOCAL_USER}',
  'password' => '${_DATABASE_LOCAL_PASSWORD}',
  'host' => '${_DATABASE_LOCAL_HOST}',
  'prefix' => '',
  'collation' => 'utf8_general_ci',
);

EOF

  cat <<EOF | tee -a ${_SETTINGS_SITE_CONFIG} > /dev/null 2>&1
# Theme debug mode
\$conf['use_debug_theme'] = TRUE;

EOF

  cat <<EOF | tee -a ${_SETTINGS_SITE_CONFIG} > /dev/null 2>&1
# Apache Solr search application
\$conf['apachesolr_read_only'] = "1";

EOF

  cat <<EOF | tee -a ${_SETTINGS_SITE_CONFIG} > /dev/null 2>&1
# Cache session
unset(\$conf['cache_backends']);
unset(\$conf['cache_default_class']);
unset(\$conf['cache_class_cache_form']);
unset(\$conf['cache_class_cache_entity_bean']);

EOF

  if [ -f "${_SETTINGS_SITE_CONFIG}" ]; then

    out_success "Created file ${_SETTINGS_SITE_CONFIG}"

  else

    out_danger "File ${_SETTINGS_SITE_CONFIG} not found!"

  fi

}

function local_setup_configuration_vhost() {

  local _SUBSCRIPTION_PATH="/var/www/html/open_solutions/web/${_LOCAL_SETUP_PLATFORM_ACQUIA_BRANCH_OUT}/docroot"
  local _SUBSCRIPTION_WEB_PATH="${_LOCAL_SETUP_WEB_WORKSPACE}/${_LOCAL_SETUP_PLATFORM_ACQUIA_BRANCH_OUT}"
  local _LOCAL_SETUP_DOMAIN_LIST=$(site_configuration_get_subscription_domains ${_LOCAL_SETUP_SUBSCRIPTION} "local")
  local _LOCAL_SETUP_VHOST="${_LOCAL_SETUP_CONFIGS}/vhosts.conf"

  if [ ! -d ${_LOCAL_SETUP_CONFIGS} ]; then

   filesystem_create_folder_777 ${_LOCAL_SETUP_CONFIGS}

  fi


  if [ ! -d ${_SUBSCRIPTION_WEB_PATH} ]; then

    raise RequiredFolderNotFound "[local_setup_configuration_vhost] Folder ${_SUBSCRIPTION_WEB_PATH} not exists. Please provide a valid folder"

  fi

  if [[ -z ${_LOCAL_SETUP_DOMAIN_LIST} ]]; then

    raise RequiredParameterNotFound "[local_setup_configuration_vhost] Please provide a valid domain"

  fi

  # Generate vitualhost based macro
  apache_generate_vhost_macro ${_SUBSCRIPTION_PATH} ${_LOCAL_SETUP_VHOST} ${_LOCAL_SETUP_DOMAIN_LIST}

}

function local_setup_configuration_host() {

  local _LOCAL_SETUP_DOMAIN_LIST=$(site_configuration_get_subscription_domains ${_LOCAL_SETUP_SUBSCRIPTION} "local")


  local _LOCAL_SETUP_CONTAINER_WEB_IP=$(docker_get_ip ${_LOCAL_SETUP_DOCKER_CONTAINER_WEB})

  sudo ${_SED} -i "/# ${_LOCAL_SETUP_SUBSCRIPTION^^}/,/# ${_LOCAL_SETUP_SUBSCRIPTION^^}/d" /etc/hosts > /dev/null 2>&1
  out_info "Updating /etc/hosts" 1
  # Update /etc/hosts hostnames
  local _SUB_SITE_LIST="${_LOCAL_SETUP_SUBSCRIPTION}.localhost ${_LOCAL_SETUP_DOMAIN_LIST}"
  echo -e "# ${_LOCAL_SETUP_SUBSCRIPTION^^} #################################################################################################" |sudo tee -a /etc/hosts > /dev/null 2>&1
  echo "${_LOCAL_SETUP_CONTAINER_WEB_IP} ${_LOCAL_SETUP_DOMAIN_LIST}" |sudo tee -a /etc/hosts > /dev/null 2>&1
  echo -e "# ${_LOCAL_SETUP_SUBSCRIPTION^^} #################################################################################################" |sudo tee -a /etc/hosts > /dev/null 2>&1
  out_check_status $? "Update successfully" "Error while on update file in /etc/hosts"

}

function local_setup_site_update_multilanguage_via_container() {

  local _SUBSITE_REAL_NAME=$(site_configuration_get_subsite_name ${_LOCAL_SETUP_SUBSITE} ${_LOCAL_SETUP_SUBSCRIPTION})
  local _SUBSITE_FOLDER="${_LOCAL_SETUP_SUBSCRIPTION_WEB_SITE_REAL_PATH}/${_SUBSITE_REAL_NAME}"

  out_info "Configure site multilanguage" 1
  local _DOMAIN_LIST=""
  if (site_configuration_is_subsite_multi_language ${_LOCAL_SETUP_SUBSITE} ${_LOCAL_SETUP_SUBSCRIPTION}); then

    out_info "Site ${_LOCAL_SETUP_SUBSITE} is multilanguage" 1
    local _SUBSITE_LANGUAGE_LIST=$(site_configuration_get_subsite_languages ${_LOCAL_SETUP_SUBSITE} ${_LOCAL_SETUP_SUBSCRIPTION})
    local _SUBSITE_LANGUAGE_LIST=$(echo -e ${_SUBSITE_LANGUAGE_LIST}|sed "s/ /\n/g"|sort -u |uniq)

    for _LANGUAGE in ${_SUBSITE_LANGUAGE_LIST}; do

      #Get domains from language and subsite
      local _SUBSITE_MULTI_DOMAIN_LIST=$(site_configuration_get_subsite_domains_by_env ${_LOCAL_SETUP_SUBSITE} ${_LOCAL_SETUP_SUBSCRIPTION} "local" ${_LANGUAGE})
      _DOMAIN_LIST="${_DOMAIN_LIST} ${_SUBSITE_MULTI_DOMAIN_LIST}"

      out_info "Adding domains [ ${_DOMAIN_LIST} ] for ${_LOCAL_SETUP_SUBSITE}" 1
      #Format output
      local _DOMAIN_LIST_FORMATED_FOR_UPDATE=$(echo -e ${_DOMAIN_LIST}|sed "s/ /\n/g"|sort -u |uniq)
      local _LANG_UPDATE=$(site_configuration_get_real_language ${_LANGUAGE})

      if [ -z ${_LANG_UPDATE} ]; then

        out_warning "Language ${_LANGUAGE} not mapped."
        # Clean variable
        local _DOMAIN_LIST=""

        continue;

      fi
      local _COMMAND_LANG="${_LOCAL_SETUP_DATABASE_SCRIPT} lang ${_LOCAL_SETUP_PLATFORM_ACQUIA_BRANCH_OUT} ${_LOCAL_SETUP_SUBSITE_REAL_NAME} ${_LANG_UPDATE} '${_DOMAIN_LIST_FORMATED_FOR_UPDATE}'"
      docker_exec ${_LOCAL_SETUP_DOCKER_CONTAINER_CLI} "${_COMMAND_LANG}"

      # Clean variable
      local _DOMAIN_LIST=""

    done

    local _COMMAND_MULTILANGUAL="${_LOCAL_SETUP_DATABASE_SCRIPT} multilingual ${_LOCAL_SETUP_PLATFORM_ACQUIA_BRANCH_OUT} ${_LOCAL_SETUP_SUBSITE_REAL_NAME}"
    docker_exec ${_LOCAL_SETUP_DOCKER_CONTAINER_CLI} "${_COMMAND_MULTILANGUAL}"

  else

    out_info "Site ${_LOCAL_SETUP_SUBSITE} is not multilanguage" 1

  fi

}


function local_setup_site_update_multilanguage() {

  local _SUBSITE_REAL_NAME=$(site_configuration_get_subsite_name ${_LOCAL_SETUP_SUBSITE} ${_LOCAL_SETUP_SUBSCRIPTION})
  local _SUBSITE_FOLDER="${_LOCAL_SETUP_SUBSCRIPTION_WEB_SITE_REAL_PATH}/${_SUBSITE_REAL_NAME}"

  if [ -d "${_SUBSITE_FOLDER}" ] && [ ! -z ${_SUBSITE_REAL_NAME} ]; then

    ${_CD} "${_SUBSITE_FOLDER}"
    local _LOCAL_SETUP_DATABASE_CONNECTION=$(site_configuration_get_subsite_database_connection ${_LOCAL_SETUP_SUBSCRIPTION} ${_LOCAL_SETUP_SUBSITE} "local")

    out_info "Configure site multilanguage" 1
    if (mysql_validate_connection "${_LOCAL_SETUP_DATABASE_CONNECTION}"); then

      local _DOMAIN_LIST=""
      if (site_configuration_is_subsite_multi_language ${_LOCAL_SETUP_SUBSITE} ${_LOCAL_SETUP_SUBSCRIPTION}); then

        out_info "Site ${_LOCAL_SETUP_SUBSITE} is multilanguage" 1
        local _SUBSITE_LANGUAGE_LIST=$(site_configuration_get_subsite_languages ${_LOCAL_SETUP_SUBSITE} ${_LOCAL_SETUP_SUBSCRIPTION})

        for _LANGUAGE in ${_SUBSITE_LANGUAGE_LIST}; do

          #Get domains from language and subsite
          local _SUBSITE_MULTI_DOMAIN_LIST=$(site_configuration_get_subsite_domains_by_env ${_LOCAL_SETUP_SUBSITE} ${_LOCAL_SETUP_SUBSCRIPTION} "local" ${_LANGUAGE})
          _DOMAIN_LIST="${_DOMAIN_LIST} ${_SUBSITE_MULTI_DOMAIN_LIST}"

          out_info "Adding domains [ ${_DOMAIN_LIST} ] for ${_LOCAL_SETUP_SUBSITE}" 1
          #Format output
          local _DOMAIN_LIST_FORMATED_FOR_UPDATE=$(echo ${_DOMAIN_LIST} | sed "s/ /,/g")
          drush_add_language_domains ${_LANGUAGE} "${_DOMAIN_LIST_FORMATED_FOR_UPDATE}"

          # Clean variable
          local _DOMAIN_LIST=""

        done

      else

        out_info "Site ${_LOCAL_SETUP_SUBSITE} is not multilanguage" 1

      fi

    fi

  fi
}

function local_setup_platform_list_domains() {

  out_warning "Local setup finished for ${_LOCAL_SETUP_SUBSITE}" 1
  out_info "Domains list:" 1

  local _LOCAL_SETUP_DOMAIN_LIST=$(site_configuration_get_domains ${_LOCAL_SETUP_SUBSCRIPTION} "local" ${_LOCAL_SETUP_SUBSITE})

  for _DOMAINS_LIST in ${_LOCAL_SETUP_DOMAIN_LIST}; do

    echo -e "  ${BGREEN} http://${_DOMAINS_LIST} ${COLOR_OFF}"

  done

  echo -e "\n  ${BGREEN} Site instalation path: >> ${_LOCAL_SETUP_SUBSITE_PATH} ${COLOR_OFF}"

  echo -e "  ${BGREEN} For run grunt: >> ${_LOCAL_SETUP_SUBSCRIPTION_DOCKER_SITE_REAL_PATH}/themes ${COLOR_OFF}"

}

function local_setup_set_os_db_configuration() {

  local _LOCAL_SETUP_SUBSCRIPTION_DEV_YML="${SF_SCRIPTS_HOME}/config/${_LOCAL_SETUP_SUBSCRIPTION,,}_dev.yml"

  if [ ! -f ${_LOCAL_SETUP_SUBSCRIPTION_DEV_YML} ]; then

    ${_CP} ${_LOCAL_SETUP_YML_SUBSCRIPTION_FILE_SUBSITE} ${_LOCAL_SETUP_SUBSCRIPTION_DEV_YML}

  fi

  out_warning "Setting os_db configuration in ${_LOCAL_SETUP_SUBSCRIPTION_DEV_YML}" 1
  ${_SED} -i -E -e "s/(jnjdevmys[0-9][0-9].cit|localhost)/${_LOCAL_SETUP_DATABASE_DOCKER_CONTAINER}/g" ${_LOCAL_SETUP_SUBSCRIPTION_DEV_YML}

}

function local_setup_set_db_citdev_configuration() {

  local _LOCAL_SETUP_SUBSCRIPTION_DEV_YML="${SF_SCRIPTS_HOME}/config/${_LOCAL_SETUP_SUBSCRIPTION,,}_dev.yml"

  if [ -f ${_LOCAL_SETUP_SUBSCRIPTION_DEV_YML} ]; then

    out_warning "Setting citdev configuration in ${_LOCAL_SETUP_SUBSCRIPTION_DEV_YML}" 1
    ${_SED} -i -E -e "s/(${_LOCAL_SETUP_DATABASE_DOCKER_CONTAINER}|localhost)/${_LOCAL_SETUP_DATABASE_CITDEV}/g" ${_LOCAL_SETUP_SUBSCRIPTION_DEV_YML}

  fi

}

function local_setup_remove_resource_not_used() {

  out_warning "Detecting and removing old resources." 1
  local _LOCAL_SETUP_SUBSCRIPTIONS="${@}"
  local _LOCAL_SETUP_RESOURCES=""

  for _SUBSCRIPTION in ${_LOCAL_SETUP_SUBSCRIPTIONS}; do

    _LOCAL_SETUP_RESOURCE=$(subscription_configuration_get_plat_repo_resource ${_SUBSCRIPTION})
    _LOCAL_SETUP_RESOURCES="${_LOCAL_SETUP_RESOURCE^^} ${_LOCAL_SETUP_RESOURCES}"

  done

  local _LOCAL_SETUP_RESOURCES=$(echo ${_LOCAL_SETUP_RESOURCES} | sort | uniq)
  local _LOCAL_SETUP_RESOURCES_WEB=$(filesystem_list_files_in_folder ${_LOCAL_SETUP_WEB_WORKSPACE})

  for _LOCAL_SETUP_RESOURCE_WEB in ${_LOCAL_SETUP_RESOURCES_WEB}; do

    if (! in_list? ${_LOCAL_SETUP_RESOURCE_WEB} "${_LOCAL_SETUP_RESOURCES[@]}"); then

      local _LOCAL_SETUP_RESOURCE_PATH="${_LOCAL_SETUP_WEB_WORKSPACE}/${_LOCAL_SETUP_RESOURCE_WEB}"
      if [ -d ${_LOCAL_SETUP_RESOURCE_PATH} ]; then

        out_confirm "Do you want to remove ${_LOCAL_SETUP_RESOURCE_PATH}" 1 && true
        if [ $? -eq 0 ]; then

          out_info "Removing unused folder: ${_LOCAL_SETUP_RESOURCE_PATH}"
          filesystem_delete_folder ${_LOCAL_SETUP_RESOURCE_PATH}
          out_check_status $? "Folder ${_LOCAL_SETUP_RESOURCE_PATH} removed successfully." "Error while removing folder ${_LOCAL_SETUP_RESOURCE_PATH}"

        fi

      fi

    fi

  done

}
