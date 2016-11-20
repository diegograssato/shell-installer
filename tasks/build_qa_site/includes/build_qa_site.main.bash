#!/usr/bin/env bash


function build_qa_site_load_configurations() {

  if [ -z ${1:-} ]; then

    raise RequiredParameterNotFound "[build_qa_site_load_configurations] Please provide a valid site"

  else

    _BUILD_QA_SITE_SUBSITE=${1}

  fi

  if [ -z ${2:-} ]; then

    raise RequiredParameterNotFound "[build_qa_site_load_configurations] Please provide a valid subscription"

  else

    _BUILD_QA_SITE_SUBSCRIPTION=${2}

  fi

  if [ -z ${3:-} ]; then

    _BUILD_QA_SITE_MOVE_DB="false"

  else

    _BUILD_QA_SITE_MOVE_DB=${3}

  fi

  local _YML_SUBSCRIPTION_FILE_CONFIGURATION="${SF_SCRIPTS_HOME}/config/subscriptions.yml"
  local _YML_SUBSCRIPTION_FILE_SUBSITE="${SF_SCRIPTS_HOME}/config/${_BUILD_QA_SITE_SUBSCRIPTION:-}.yml"

  if [ ! -f "${_YML_SUBSCRIPTION_FILE_CONFIGURATION}" ]; then

    raise FileNotFound "[build_qa_site_load_configurations] File ${_YML_SUBSCRIPTION_FILE_CONFIGURATION} not found!"

  else

    eval $(yml_loader ${_YML_SUBSCRIPTION_FILE_CONFIGURATION} "_")

  fi

  if [ -z "${_YML_SUBSCRIPTION_FILE_SUBSITE}" ]; then

    raise FileNotFound "[build_qa_site_load_configurations] File ${_YML_SUBSCRIPTION_FILE_SUBSITE} not found!"

  else

    eval $(yml_loader ${_YML_SUBSCRIPTION_FILE_SUBSITE} "_")

  fi

  out_warning "Loading configurations" 1

  # Setup initials variables
  _BUILD_QA_SITE_SUBSITE_REPO=$(site_configuration_get_subsite_repo ${_BUILD_QA_SITE_SUBSITE} ${_BUILD_QA_SITE_SUBSCRIPTION})
  _BUILD_QA_SITE_SUBSITE_BRANCH=$(site_configuration_get_subsite_branch ${_BUILD_QA_SITE_SUBSITE} ${_BUILD_QA_SITE_SUBSCRIPTION})
  _BUILD_QA_SITE_REAL_NAME=$(site_configuration_get_subsite_name ${_BUILD_QA_SITE_SUBSITE} ${_BUILD_QA_SITE_SUBSCRIPTION})

  _BUILD_QA_SITE_PLATFORM_PLATFORM_REPO=$(subscription_configuration_get_repository ${_BUILD_QA_SITE_SUBSCRIPTION})
  _BUILD_QA_SITE_PLATFORM_ACQUIA_BRANCH=$(subscription_configuration_get_plat_repo_resource ${_BUILD_QA_SITE_SUBSCRIPTION})
  _BUILD_QA_SITE=$(subscription_configuration_get_sites ${_BUILD_QA_SITE_SUBSCRIPTION})

  # Setup others variables
  _BUILD_QA_SITE_SUBSITE_PATH="${_BUILD_QA_SITE_WORKSPACE}/sites/${_BUILD_QA_SITE_SUBSITE}"
  _BUILD_QA_SITE_SUBSCRIPTION_PATH="${_BUILD_QA_SITE_WORKSPACE}/subscriptions/${_BUILD_QA_SITE_SUBSCRIPTION}"

  _BUILD_QA_SITE_APACHE_SUBSCRIPTION_PATH="${_BUILD_QA_SITE_APACHE_PATH}/${_BUILD_QA_SITE_SUBSCRIPTION}/docroot"
  _BUILD_QA_SITE_APACHE_SUBSITE_PATH="${_BUILD_QA_SITE_APACHE_SUBSCRIPTION_PATH}/sites/${_BUILD_QA_SITE_REAL_NAME}"

  # if is jenkins change container name
  if [ ! -z ${JENKINS_HOME+x} ]; then

    _BUILD_QA_SITE_DOCKER_CONTAINER=${SF_SCRIPTS_CONTAINER_CLI_NAME}

  fi

}

function build_qa_site_database_move() {

  if [ "${_BUILD_QA_SITE_MOVE_DB}" == "true" ]; then

    local _LOCAL_DB=$(site_configuration_get_subsite_database_connection ${_BUILD_QA_SITE_SUBSCRIPTION} ${_BUILD_QA_SITE_SUBSITE} ${_BUILD_QA_SITE_DB_SRC})
    local _QA_DB=$(site_configuration_get_subsite_database_connection ${_BUILD_QA_SITE_SUBSCRIPTION} ${_BUILD_QA_SITE_SUBSITE} ${_BUILD_QA_SITE_DB_DST})

    out_warning "Moving database from ${_BUILD_QA_SITE_DB_SRC} to ${_BUILD_QA_SITE_DB_DST}" 1

    # TODO Implement zcat | drush sqlc approach instead of basic database_move
    database_move "${_LOCAL_DB}" "${_QA_DB}"

  fi

}

function build_qa_site_apache_rsync() {

  if [ -z ${1:-} ]; then

    raise RequiredParameterNotFound "[build_qa_site_apache_rsync] Please provide a valid site"

  else

    _BUILD_QA_SITE_SUBSITE=${1}

  fi

  if [ -z ${2:-} ]; then

    raise RequiredParameterNotFound "[build_qa_site_apache_rsync] Please provide a valid subscription"

  else

    _BUILD_QA_SITE_SUBSCRIPTION=${2}

  fi

  out_warning "Mounting code from repositories" 1
  local _BUILD_QA_SITE_PLATFORM_FLAGS='--update --delete --include=".*" --include="sites/all" --include="sites/sites.php" --include="sites/default" --mode="Cav"'
  local _BUILD_QA_SITE_SITE_FLAGS='--update --delete --include="debug/styles/sass/core" --exclude="release" --exclude="/js/js_*" --exclude="/css/css_*" --exclude="node_modules" --exclude=".sass-cache" --mode="Cav"'
  # drush_rsync_clean "${_BUILD_QA_SITE_SUBSCRIPTION_PATH}/docroot/" "${_BUILD_QA_SITE_APACHE_PATH}/${_BUILD_QA_SITE_SUBSCRIPTION}/" "-y" "${_BUILD_QA_SITE_PLATFORM_FLAGS}"
  if [ ! -d ${_BUILD_QA_SITE_APACHE_PATH}/${_BUILD_QA_SITE_SUBSCRIPTION} ]; then
    ${_MKDIR} -p ${_BUILD_QA_SITE_APACHE_PATH}/${_BUILD_QA_SITE_SUBSCRIPTION}
  fi
  out_info "Copying platform from ${_BUILD_QA_SITE_SUBSCRIPTION_PATH}/docroot/ to ${_BUILD_QA_SITE_APACHE_PATH}/${_BUILD_QA_SITE_SUBSCRIPTION}/"
  ${_CP} -a ${_BUILD_QA_SITE_SUBSCRIPTION_PATH}/* ${_BUILD_QA_SITE_APACHE_PATH}/${_BUILD_QA_SITE_SUBSCRIPTION}/

  out_check_status $? "Platform code updated successfully" "Error while copying platform code"
  drush_rsync_clean "${_BUILD_QA_SITE_SUBSITE_PATH}/src/" "${_BUILD_QA_SITE_APACHE_SUBSITE_PATH}" "-y" "${_BUILD_QA_SITE_SITE_FLAGS}"

}

function build_qa_site_move_files() {

  if [ -z ${1:-} ]; then

    raise RequiredParameterNotFound "[setup_qa_files_symlink] Please provide a valid site"

  else

    local _BUILD_QA_SITE_SUBSITE=${1}

  fi

  if [ -z ${2:-} ]; then

    raise RequiredParameterNotFound "[setup_qa_files_symlink] Please provide a valid subscription"

  else

    local _BUILD_QA_SITE_SUBSCRIPTION=${2}

  fi

  out_warning "Copying files folder from ${_BUILD_QA_SITE_SUBSITE} subsite" 1

  local _BUILD_QA_SITE_SUBSITE_FILES_PATH="/nfs/subscriptions/${_BUILD_QA_SITE_SUBSCRIPTION}/sites/${_BUILD_QA_SITE_REAL_NAME}/files"

  if [ -d "${_BUILD_QA_SITE_SUBSITE_FILES_PATH}" ]; then

    if [ ! -d "${_BUILD_QA_SITE_APACHE_SUBSITE_PATH}/files" ]; then

      out_info "${_BUILD_QA_SITE_APACHE_SUBSITE_PATH}/files directory not found, creating it"
      ${_MKDIR} "${_BUILD_QA_SITE_APACHE_SUBSITE_PATH}/files"

    fi

    ${_CP} -vur ${_BUILD_QA_SITE_SUBSITE_FILES_PATH} ${_BUILD_QA_SITE_APACHE_SUBSITE_PATH}
    out_check_status $? "Files copied successfully" "Error while copying files"
    sudo ${_CHMOD} 777 ${_BUILD_QA_SITE_APACHE_SUBSITE_PATH} -R

  else

    out_warning "Files server not found, skipping files. Probably building locally to test."

  fi

}

function build_qa_site_local_configs() {

  out_warning "Setting up local configurations" 1
  build_qa_site_create_subscription_sites_local
  build_qa_site_create_subsite_settings

}

function build_qa_site_database_update_configs() {

  ${_CD} ${_BUILD_QA_SITE_APACHE_SUBSITE_PATH}

  if [ "${_BUILD_QA_SITE_MOVE_DB}" == "true" ]; then
    if [ -z ${1:-} ]; then

      raise RequiredParameterNotFound "[build_qa_site_database_update_configs] Please provide a valid site"

    else

      local _BUILD_QA_SITE_SUBSITE=${1}

    fi

    if [ -z ${2:-} ]; then

      raise RequiredParameterNotFound "[build_qa_site_database_update_configs] Please provide a valid subscription"

    else

      local _BUILD_QA_SITE_SUBSCRIPTION=${2}

    fi

    out_warning "Updating local configurations" 1

    build_qa_site_update_configs

    #TODO Implement multilanguage URL update
    build_qa_site_update_multilanguage ${_BUILD_QA_SITE_SUBSITE}

  fi

  out_info "Clearing Drupal cache"
  drush_command "cc all"

}
