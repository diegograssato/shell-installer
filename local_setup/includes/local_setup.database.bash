#!/usr/bin/env bash

function local_setup_database_sync() {

  local _LOCAL_SETUP_SUBSITE_REAL_NAME=$(site_configuration_get_subsite_name ${_LOCAL_SETUP_SUBSITE} ${_LOCAL_SETUP_SUBSCRIPTION})
  local _LOCAL_SETUP_OUTPUT_DUMP_DIR="/tmp"
  local _LOCAL_SETUP_UTPUT_DUMP_FILE="${_LOCAL_SETUP_OUTPUT_DUMP_DIR}/${_LOCAL_SETUP_SUBSITE_REAL_NAME}.sql.gz"
  local _SUBSITE_FOLDER="${_LOCAL_SETUP_SUBSCRIPTION_WEB_SITE_REAL_PATH}/${_LOCAL_SETUP_SUBSITE_REAL_NAME}"
  local _LOCAL_SETUP_DATABASE_CONNECTION=$(site_configuration_get_subsite_database_connection ${_LOCAL_SETUP_SUBSCRIPTION} ${_LOCAL_SETUP_SUBSITE} "local")

  if (mysql_validate_connection "${_LOCAL_SETUP_DATABASE_CONNECTION}"); then

    if [ ! -f ${_LOCAL_SETUP_UTPUT_DUMP_FILE} ]; then

      acquia_subsite_mysqldump_no_cache ${_LOCAL_SETUP_SUBSCRIPTION} ${_LOCAL_SETUP_SUBSCRIPTION_ENVIRONMENT} "${_LOCAL_SETUP_SUBSITE_REAL_NAME}" "${_LOCAL_SETUP_OUTPUT_DUMP_DIR}"

    fi

    out_info "Import database file ${_LOCAL_SETUP_UTPUT_DUMP_FILE}" 1
    database_import ${_SUBSITE_FOLDER} ${_LOCAL_SETUP_UTPUT_DUMP_FILE}
    out_check_status $? "Database file imported successfully" "Error while database file import"
    ${_RM} ${_LOCAL_SETUP_UTPUT_DUMP_FILE}

  fi

}

function local_setup_database_update_configs() {

  local _LOCAL_SETUP_OUTPUT_DUMP_DIR="/tmp"
  local _SUBSITE_FOLDER="${_LOCAL_SETUP_SUBSCRIPTION_WEB_SITE_REAL_PATH}/${_LOCAL_SETUP_SUBSITE_REAL_NAME}"

  if [ ! -d ${_SUBSITE_FOLDER} ]; then

    raise RequiredFolderNotFound "[local_setup_database_update_configs] Folder ${_SUBSITE_FOLDER} not exists. Please provide a valid folder"

  fi

  ${_CD} ${_SUBSITE_FOLDER}

  local _LOCAL_SETUP_DATABASE_CONNECTION=$(site_configuration_get_subsite_database_connection ${_LOCAL_SETUP_SUBSCRIPTION} ${_LOCAL_SETUP_SUBSITE} "local")

  if (mysql_validate_connection "${_LOCAL_SETUP_DATABASE_CONNECTION}"); then

    if [ -d ${_SUBSITE_FOLDER} ] && [ ! -z ${_LOCAL_SETUP_SUBSITE} ]; then

      out_info "Updating local database settings ${_SUBSITE_FOLDER}"
      # DEPRECATED: line below used the old version
      # site_configuration_configure_database_to_developer ${_SUBSITE_FOLDER}
      site_configuration_set_configs "dev"
      out_check_status $? "Database updated successfully" "Error while database updating"

    fi

  fi

}

function local_setup_database_update_reference() {

  _IP=$(docker_get_ip ${_LOCAL_SETUP_DATABASE_DOCKER_CONTAINER})
  sudo ${_SED} -i "/${_LOCAL_SETUP_DATABASE_DOCKER_CONTAINER}/d" /etc/hosts
  echo  ${_IP}    ${_LOCAL_SETUP_DATABASE_DOCKER_CONTAINER} "db.opensolutions.docker" |sudo tee -a /etc/hosts
  echo "grant all on *.* to open_solutions@'%' identified by 'open_solutions';" | mysql -u root -h ${_LOCAL_SETUP_DATABASE_DOCKER_CONTAINER}

}
