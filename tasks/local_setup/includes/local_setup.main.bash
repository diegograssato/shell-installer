#!/usr/bin/env bash


function local_setup_load_configurations() {

  if [ -z ${1:-} ]; then

    raise RequiredParameterNotFound "[local_setup_load_configurations] Please provide a valid site"

  else

    _LOCAL_SETUP_SUBSITE=${1}

  fi


  if [ -z ${2:-} ]; then

    raise RequiredParameterNotFound "[local_setup_load_configurations] Please provide a valid subscription"

  else

    _LOCAL_SETUP_SUBSCRIPTION=${2}

  fi

  if [ -z ${3:-} ]; then

    _LOCAL_SETUP_SUBSCRIPTION_ENVIRONMENT="test"

  else

    _LOCAL_SETUP_SUBSCRIPTION_ENVIRONMENT=${3}

  fi

  if [ -z ${4:-} ]; then

    _LOCAL_SETUP_MOVE_DB="false"

  else

    _LOCAL_SETUP_MOVE_DB=${4}

    if [ "${_LOCAL_SETUP_MOVE_DB}" == 1 ]; then

      _LOCAL_SETUP_MOVE_DB="true"

    elif [ "${_LOCAL_SETUP_MOVE_DB}" == 0 ]; then

      _LOCAL_SETUP_MOVE_DB="false"

    fi

  fi

  if [ -z ${5:-} ]; then

    _LOCAL_SETUP_DB_TYPE=${_LOCAL_SETUP_PARAMETER_DB_CITDEV}

  else

    _LOCAL_SETUP_DB_TYPE=${5}

    if [ ! ${_LOCAL_SETUP_DB_TYPE} == ${_LOCAL_SETUP_PARAMETER_DB_CITDEV} ] && [ ! ${_LOCAL_SETUP_DB_TYPE} == ${_LOCAL_SETUP_PARAMETER_DB_LOCAL} ]; then

      raise InvalidParameter "[local_setup_load_configurations] Database type must be '${_LOCAL_SETUP_PARAMETER_DB_CITDEV}' or '${_LOCAL_SETUP_PARAMETER_DB_LOCAL}'"

    fi

  fi

  if [ -z ${6:-} ]; then

    _LOCAL_SETUP_SYNC_FILES="true"

  else

    _LOCAL_SETUP_SYNC_FILES=${6}

    if [ "${_LOCAL_SETUP_SYNC_FILES}" == 1 ]; then

      _LOCAL_SETUP_SYNC_FILES="true"

    elif [ "${_LOCAL_SETUP_SYNC_FILES}" == 0 ]; then

      _LOCAL_SETUP_SYNC_FILES="false"

    fi

  fi

  out_warning "Loading configurations" 1
  sudo echo -n ""

  local _LOCAL_SETUP_YML_SUBSCRIPTION_FILE_CONFIGURATION="${SF_SCRIPTS_HOME}/config/subscriptions.yml"
  local _LOCAL_SETUP_YML_SUBSCRIPTION_FILE_CONFIGURATION_DEV="${SF_SCRIPTS_HOME}/config/subscriptions_dev.yml"
  local _LOCAL_SETUP_YML_SUBSCRIPTION_FILE_SUBSITE="${SF_SCRIPTS_HOME}/config/${_LOCAL_SETUP_SUBSCRIPTION:-}.yml"

  if [ ! -f "${_LOCAL_SETUP_YML_SUBSCRIPTION_FILE_CONFIGURATION}" ]; then

    raise FileNotFound "[local_setup_load_configurations] File ${_LOCAL_SETUP_YML_SUBSCRIPTION_FILE_CONFIGURATION} not found!"

  else

    yml_parse ${_LOCAL_SETUP_YML_SUBSCRIPTION_FILE_CONFIGURATION} "_"
    # Added second parser from YAML, more complex and complete;
    yay ${_LOCAL_SETUP_YML_SUBSCRIPTION_FILE_CONFIGURATION} "_"

  fi

  if [ -f "${_LOCAL_SETUP_YML_SUBSCRIPTION_FILE_CONFIGURATION_DEV}" ]; then

    yml_parse ${_LOCAL_SETUP_YML_SUBSCRIPTION_FILE_CONFIGURATION_DEV} "_"
    # Added second parser from YAML, more complex and complete;
    yay ${_LOCAL_SETUP_YML_SUBSCRIPTION_FILE_CONFIGURATION_DEV} "_"

  fi

  if [ ! -f "${_LOCAL_SETUP_YML_SUBSCRIPTION_FILE_SUBSITE}" ]; then

    raise FileNotFound "[local_setup_load_configurations] Missing configuration file ${_LOCAL_SETUP_YML_SUBSCRIPTION_FILE_SUBSITE}"

  fi

  # Get all site if necessary
  _LOCAL_SETUP_GET_SITES=$(subscription_configuration_get_sites ${_LOCAL_SETUP_SUBSCRIPTION})
  _LOCAL_SETUP_GET_ALL_SUBSCRIPTION=$(subscription_configuration_get_all_subscriptions)
  _LOCAL_SETUP_PLATFORM_VERSION=$(subscription_configuration_get_plat_repo_resource ${_LOCAL_SETUP_SUBSCRIPTION})
  _LOCAL_SETUP_SUBSCRIPTION_SAME_VERSION=$(subscription_configuration_get_platforms_same_version ${_LOCAL_SETUP_PLATFORM_VERSION} ${_LOCAL_SETUP_GET_ALL_SUBSCRIPTION})
  _LOCAL_SETUP_GET_SITES_SAME_VERSION=$(subscription_configuration_get_sites_in_same_platform_version ${_LOCAL_SETUP_SUBSCRIPTION_SAME_VERSION})

  local_setup_switch_database_configuration

  for _SUBSCRIPTION in ${_LOCAL_SETUP_SUBSCRIPTION_SAME_VERSION}; do

    local _LOCAL_SETUP_YML_SUBSCRIPTION_FILE_SUBSITES="${SF_SCRIPTS_HOME}/config/${_SUBSCRIPTION,,}.yml"
    local _LOCAL_SETUP_YML_SUBSCRIPTION_FILE_SUBSITES_DEV="${SF_SCRIPTS_HOME}/config/${_SUBSCRIPTION,,}_dev.yml"

    if [ -f "${_LOCAL_SETUP_YML_SUBSCRIPTION_FILE_SUBSITES}" ]; then

      yml_parse ${_LOCAL_SETUP_YML_SUBSCRIPTION_FILE_SUBSITES} "_"

    fi

    if [ -f "${_LOCAL_SETUP_YML_SUBSCRIPTION_FILE_SUBSITES_DEV}" ]; then

      yml_parse ${_LOCAL_SETUP_YML_SUBSCRIPTION_FILE_SUBSITES_DEV} "_"

    fi

  done

  # Setup initials variables
  _LOCAL_SETUP_SUBSITE_REPO=$(site_configuration_get_subsite_repo ${_LOCAL_SETUP_SUBSITE} ${_LOCAL_SETUP_SUBSCRIPTION})

  _LOCAL_SETUP_SUBSITE_BRANCH=$(site_configuration_get_subsite_branch ${_LOCAL_SETUP_SUBSITE} ${_LOCAL_SETUP_SUBSCRIPTION})
  _LOCAL_SETUP_SUBSITE_REAL_NAME=$(site_configuration_get_subsite_name ${_LOCAL_SETUP_SUBSITE} ${_LOCAL_SETUP_SUBSCRIPTION})


  # Validate if subiste exists
  if [ -z ${_LOCAL_SETUP_SUBSITE_REAL_NAME} ] || [ -z ${_LOCAL_SETUP_SUBSITE_BRANCH} ] || [ -z ${_LOCAL_SETUP_SUBSITE_REPO} ]; then

    out_danger "Site '${_LOCAL_SETUP_SUBSITE}' not exists, select one from the list:" 1
    for SITE in ${_LOCAL_SETUP_GET_SITES}; do

      echo -e "  ${BGREEN} ${SITE} ${COLOR_OFF}"

    done

    raise RequiredSiteNotFound "[local_setup_load_configurations] Site '${_LOCAL_SETUP_SUBSITE}' does not exist, please provid a valid site"

  elif (subscription_configuration_check_site_exists_in_sub ${_LOCAL_SETUP_SUBSCRIPTION} ${_LOCAL_SETUP_SUBSITE}); then

    raise MissingRequiredConfig "[local_setup_load_configurations] Subsite not found in configuration file ${_LOCAL_SETUP_YML_SUBSCRIPTION_FILE_CONFIGURATION}"

  fi

  if [ ! -f "${_SF_SCRIPTS_CONFIG}/docker-compose.yml" ]; then

    raise FileNotFound "[local_setup_load_configurations] Missing configuration file ${_SF_SCRIPTS_CONFIG}/docker-compose.yml"

  fi

  _LOCAL_SETUP_DOCKER_COMPOSE_FILE="${_SF_SCRIPTS_CONFIG}/docker-compose.yml"

  _LOCAL_SETUP_PLATFORM_PLATFORM_REPO=$(subscription_configuration_get_repository ${_LOCAL_SETUP_SUBSCRIPTION})
  _LOCAL_SETUP_PLATFORM_PLATFORM_REPO_NAME=$(git_extract_repository_name "${_LOCAL_SETUP_PLATFORM_PLATFORM_REPO}")
  _LOCAL_SETUP_PLATFORM_ACQUIA_BRANCH=$(subscription_configuration_get_plat_repo_resource ${_LOCAL_SETUP_SUBSCRIPTION})
  _LOCAL_SETUP_PLATFORM_ACQUIA_BRANCH_OUT=$(subscription_configuration_get_platform_path ${_LOCAL_SETUP_SUBSCRIPTION})

  # Setup others variables
  _LOCAL_SETUP_SUBSCRIPTION_PATH="${_LOCAL_SETUP_WORKSPACE}/subscriptions/${_LOCAL_SETUP_PLATFORM_PLATFORM_REPO_NAME}"
  _LOCAL_SETUP_SUBSCRIPTION_WEB_PATH="${_LOCAL_SETUP_WORKSPACE}/web/${_LOCAL_SETUP_PLATFORM_ACQUIA_BRANCH_OUT}"
  _LOCAL_SETUP_SUBSCRIPTION_WEB_SITE_PATH="${_LOCAL_SETUP_SUBSCRIPTION_WEB_PATH}/sites"
  _LOCAL_SETUP_SUBSCRIPTION_WEB_SITE_REAL_PATH="${_LOCAL_SETUP_SUBSCRIPTION_WEB_PATH}/docroot/sites"
  _LOCAL_SETUP_SUBSCRIPTION_DOCKER_SITE_REAL_PATH="${_LOCAL_SETUP_SUBSCRIPTION_WEB_PATH}/docroot/sites/${_LOCAL_SETUP_SUBSITE_REAL_NAME}"
  _LOCAL_SETUP_SUBSITE_PATH="${_LOCAL_SETUP_SUBSCRIPTION_WEB_SITE_PATH}/${_LOCAL_SETUP_SUBSITE}"
  _LOCAL_SETUP_APACHE_SUBSCRIPTION_PATH="${_LOCAL_SETUP_WEB_WORKSPACE}/${_LOCAL_SETUP_SUBSCRIPTION}"
  _LOCAL_SETUP_APACHE_SUBSITE_PATH="${_LOCAL_SETUP_WEB_WORKSPACE}/sites/${_LOCAL_SETUP_SUBSITE_REAL_NAME}"
  _LOCAL_SETUP_SUBSCRIPTION_WEB_SUBSITE_REAL_PATH="${_LOCAL_SETUP_SUBSCRIPTION_DOCKER_SITE_REAL_PATH}/${_LOCAL_SETUP_SUBSITE_REAL_NAME}"

}

function local_setup_switch_database_configuration() {

  case ${_LOCAL_SETUP_DB_TYPE} in

    ${_LOCAL_SETUP_PARAMETER_DB_LOCAL} )
      local_setup_set_os_db_configuration
    ;;

    ${_LOCAL_SETUP_PARAMETER_DB_CITDEV} )
      local_setup_set_db_citdev_configuration
    ;;

  esac

}

function local_setup_metrics_init() {

  metrics_add ${_LOCAL_SETUP_SUBSITE}
  metrics_add ${_LOCAL_SETUP_SUBSCRIPTION}
  metrics_add ${_LOCAL_SETUP_MOVE_DB}
  metrics_add ${_LOCAL_SETUP_SUBSCRIPTION_ENVIRONMENT}

}

function local_setup_platform() {

  # Remove old resources
  local_setup_remove_resource_not_used ${_LOCAL_SETUP_GET_ALL_SUBSCRIPTION}

  git_load_repositories ${_LOCAL_SETUP_PLATFORM_PLATFORM_REPO} ${_LOCAL_SETUP_PLATFORM_ACQUIA_BRANCH} ${_LOCAL_SETUP_SUBSCRIPTION_PATH}

  out_info "Copying platform from ${_LOCAL_SETUP_SUBSCRIPTION_PATH} to ${_LOCAL_SETUP_SUBSCRIPTION_WEB_PATH}" 1
  if [ ! -d ${_LOCAL_SETUP_SUBSCRIPTION_WEB_PATH} ]; then

    ${_MKDIR} -p ${_LOCAL_SETUP_SUBSCRIPTION_WEB_PATH}

  fi

  # Include core folder as -C ignores it
  ${_RSYNC} -rCcv --include "core" ${_LOCAL_SETUP_SUBSCRIPTION_PATH}/ ${_LOCAL_SETUP_SUBSCRIPTION_WEB_PATH}/

  out_check_status $? "Platform code updated successfully" "Error while copying platform code"

}

function local_setup_site_repository() {

  if [ ! -d "${_LOCAL_SETUP_SUBSCRIPTION_WEB_SITE_PATH}" ]; then

    ${_MKDIR} "${_LOCAL_SETUP_SUBSCRIPTION_WEB_SITE_PATH}"

  fi

  local_setup_check_unused_folders ${_LOCAL_SETUP_SUBSCRIPTION_WEB_SITE_PATH}

  git_load_repositories ${_LOCAL_SETUP_SUBSITE_REPO} ${_LOCAL_SETUP_SUBSITE_BRANCH} ${_LOCAL_SETUP_SUBSITE_PATH}

  if [ ! -L "${_LOCAL_SETUP_SUBSCRIPTION_WEB_SITE_REAL_PATH}/${_LOCAL_SETUP_SUBSITE_REAL_NAME}" ]; then

    out_info "Creating subsite link [ ../../sites/${_LOCAL_SETUP_SUBSITE}/src ] to [ ${_LOCAL_SETUP_SUBSCRIPTION_WEB_SITE_REAL_PATH}/${_LOCAL_SETUP_SUBSITE_REAL_NAME}] "
    ${_CD} ${_LOCAL_SETUP_SUBSCRIPTION_WEB_SITE_REAL_PATH}
    ${_LN} -s "../../sites/${_LOCAL_SETUP_SUBSITE}/src" "${_LOCAL_SETUP_SUBSCRIPTION_WEB_SITE_REAL_PATH}/${_LOCAL_SETUP_SUBSITE_REAL_NAME}"
    out_check_status $? "Link created successfully" "Error on creating link from subsite"

  fi

}

function local_setup_local_configs() {

  out_warning "Configuring local settings" 1
  local_setup_configuration_sites_php
  local_setup_configuration_settings_php
  local_setup_configuration_subsite_files
  local_setup_configuration_vhost
  local_setup_configuration_host

}

function local_setup_database() {

  if [ ${_LOCAL_SETUP_DB_TYPE} == ${_LOCAL_SETUP_PARAMETER_DB_LOCAL} ]; then

    out_warning "Configuring local database" 1

    if (! docker_container_is_running ${_LOCAL_SETUP_DATABASE_DOCKER_CONTAINER}); then

      docker_compose_up ${_LOCAL_SETUP_DOCKER_COMPOSE_FILE} ${_LOCAL_SETUP_DATABASE_DOCKER_CONTAINER}
      if [ $? -gt 0 ]; then

        raise DockerError "[local_setup_database] Please check the file ${_LOCAL_SETUP_DOCKER_COMPOSE_FILE}"

      fi

      out_info "Starting mysql in container." 1
      sleep 60;

      if (! docker_container_is_running ${_LOCAL_SETUP_DATABASE_DOCKER_CONTAINER}); then

        raise DockerError "[local_setup_database] Problem on start docker container, please check your configuration or alter the parameters"

      fi

    fi

  fi

  if [ ${_LOCAL_SETUP_MOVE_DB} == 'true' ]; then

    out_warning "Sync and configure database" 1

    local _COMMAND_DL="${_LOCAL_SETUP_DATABASE_SCRIPT} dl ${_LOCAL_SETUP_SUBSCRIPTION} ${_LOCAL_SETUP_SUBSCRIPTION_ENVIRONMENT} ${_LOCAL_SETUP_SUBSITE_REAL_NAME}"
    docker_exec ${_LOCAL_SETUP_DOCKER_CONTAINER_CLI} "${_COMMAND_DL}"

    local _COMMAND_UP="${_LOCAL_SETUP_DATABASE_SCRIPT} up ${_LOCAL_SETUP_PLATFORM_ACQUIA_BRANCH_OUT} ${_LOCAL_SETUP_SUBSITE_REAL_NAME}"
    if [ "${_LOCAL_SETUP_DB_TYPE}" == "local" ]; then

      local _DB_NAME=$(site_configuration_get_subsite_database_name ${_LOCAL_SETUP_SUBSITE} ${_LOCAL_SETUP_SUBSCRIPTION}  "local")
      local _COMMAND_UP="${_LOCAL_SETUP_DATABASE_SCRIPT} up ${_LOCAL_SETUP_PLATFORM_ACQUIA_BRANCH_OUT} ${_LOCAL_SETUP_SUBSITE_REAL_NAME} ${_DB_NAME}"

    fi

    docker_exec ${_LOCAL_SETUP_DOCKER_CONTAINER_CLI} "${_COMMAND_UP}"
    local_setup_site_update_multilanguage_via_container

    # # 1. Move local database to stage database
    # local_setup_database_sync
    #
    # # 2. Update local database settings
    # local_setup_database_update_configs
    #
    # # 3. Check if site is multilanguage and updating db
    # local_setup_site_update_multilanguage

  fi

}



function local_setup_cache_clear() {

  local _SUBSITE_FOLDER="${_LOCAL_SETUP_SUBSCRIPTION_WEB_SITE_REAL_PATH}/${_LOCAL_SETUP_SUBSITE_REAL_NAME}"

  if [ ! -d ${_SUBSITE_FOLDER} ]; then

    raise RequiredFolderNotFound "[local_setupe_cache_clear] Folder ${_SUBSITE_FOLDER} not exists. Please provide a valid folder"

  fi

  ${_CD} ${_SUBSITE_FOLDER}

  out_info "Cleanning drupal cache " 1
  drush_command cc all

}

function local_setup_docker_check_status() {

  local _LOCAL_SETUP_DOCKER_UP=false
  local _LOCAL_SETUP_DOCKER_RESTART=false
  out_warning "Starting docker Containers" 1
  for _CONTAINER in ${_LOCAL_SETUP_DOCKER_CONTAINERS}; do

    local _LOCAL_SETUP_CONTAINER_STATUS=$?

    if (! docker_container_exists ${_CONTAINER}); then

      out_warning "Container ${_CONTAINER} does not exist."
      _LOCAL_SETUP_DOCKER_UP=true

    elif (! docker_container_is_running ${_CONTAINER}); then

      out_warning "Container ${_CONTAINER} is not started."
      _LOCAL_SETUP_DOCKER_RESTART=true

    else

      out_success "Container ${_CONTAINER} is already running"

    fi

  done

  if ${_LOCAL_SETUP_DOCKER_UP}; then

    out_info "Creating containers with docker-compose up" 1
    docker_compose_up ${_LOCAL_SETUP_DOCKER_COMPOSE_FILE}
    out_check_status $? "Docker compose up finished successfully" "Error while running docker-compose up"

  elif ${_LOCAL_SETUP_DOCKER_RESTART}; then

    out_info "Restarting containers from docker-compose" 1
    docker_compose_restart ${_LOCAL_SETUP_DOCKER_COMPOSE_FILE}
    out_check_status $? "Docker compose restarted successfully" "Error while restarting docker-compose"

  fi

}

function local_setup_post_execution() {

  local_setup_platform_list_domains

  out_info "Please check the mapped ports for services" 1
  out_success "\n$(docker_list_ports)"

  out_notify "Local setup finished" "Local setup scription finished for ${_LOCAL_SETUP_SUBSITE} at ${_LOCAL_SETUP_SUBSCRIPTION}"

}
