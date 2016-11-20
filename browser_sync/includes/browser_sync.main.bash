#!/usr/bin/env bash

function browser_sync_load_configurations() {

  if [ -z ${1:-} ]; then

    raise RequiredParameterNotFound "[browser_sync_load_configurations] Please provide a valid site"

  else

    _BROWSER_SYNC_SUBSITE=${1}

  fi

  if [[ ${_BROWSER_SYNC_SUBSITE} == "stop" ]] && [[ -z ${2:-} ]]; then

    browser_sync_stop_container
    exit;

  fi

  if [ -z ${2:-} ]; then

    raise RequiredParameterNotFound "[browser_sync_load_configurations] Please provide a valid subscription"

  else

    _BROWSER_SYNC_SUBSCRIPTION=${2}

  fi

  _BROWSER_SYNC_SITE_URL=${3:-}

  out_warning "Loading configurations" 1

  local _BROWSER_SYNC_YML_SUBSCRIPTION_FILE_CONFIGURATION="${SF_SCRIPTS_HOME}/config/subscriptions.yml"
  local _BROWSER_SYNC_YML_SUBSCRIPTION_FILE_SUBSITE="${SF_SCRIPTS_HOME}/config/${_BROWSER_SYNC_SUBSCRIPTION:-}.yml"

  if [ ! -f "${_BROWSER_SYNC_YML_SUBSCRIPTION_FILE_CONFIGURATION}" ]; then

    raise FileNotFound "[browser_sync_load_configurations] File ${_BROWSER_SYNC_YML_SUBSCRIPTION_FILE_CONFIGURATION} not found!"

  else

    eval $(yml_loader ${_BROWSER_SYNC_YML_SUBSCRIPTION_FILE_CONFIGURATION} "_")

  fi

  if [ ! -f "${_BROWSER_SYNC_YML_SUBSCRIPTION_FILE_SUBSITE}" ]; then

    raise FileNotFound "[browser_sync_load_configurations] Missing configuration file ${_BROWSER_SYNC_YML_SUBSCRIPTION_FILE_SUBSITE}"

  else

    eval $(yml_loader ${_BROWSER_SYNC_YML_SUBSCRIPTION_FILE_SUBSITE} "_")

  fi

  # Setup initials variables
  _BROWSER_SYNC_SUBSITE_REPO=$(site_configuration_get_subsite_repo ${_BROWSER_SYNC_SUBSITE} ${_BROWSER_SYNC_SUBSCRIPTION})
  _BROWSER_SYNC_SUBSITE_BRANCH=$(site_configuration_get_subsite_branch ${_BROWSER_SYNC_SUBSITE} ${_BROWSER_SYNC_SUBSCRIPTION})
  _BROWSER_SYNC_SUBSITE_REAL_NAME=$(site_configuration_get_subsite_name ${_BROWSER_SYNC_SUBSITE} ${_BROWSER_SYNC_SUBSCRIPTION})

  if [ -z ${_BROWSER_SYNC_SUBSITE_REAL_NAME} ]; then

    raise RequiredParameterNotFound "[browser_sync_load_configurations] Please provide a valid site"

  fi

  # Get all site if necessary
  _BROWSER_SYNC_GET_SITES=$(subscription_configuration_get_sites ${_BROWSER_SYNC_SUBSCRIPTION})

  # Validate if subiste exists
  if [ -z ${_BROWSER_SYNC_SUBSITE_REAL_NAME} ] || [ -z ${_BROWSER_SYNC_SUBSITE_BRANCH} ] || [ -z ${_BROWSER_SYNC_SUBSITE_REPO} ]; then

    out_danger "Site '${_BROWSER_SYNC_SUBSITE}' does not exist, please select one from the list:" 1
    for SITE in ${_BROWSER_SYNC_GET_SITES}; do

      echo -e "  ${BGREEN} ${SITE} ${COLOR_OFF}"

    done

    raise RequiredSiteNotFound "[browser_sync_load_configurations] Site '${_BROWSER_SYNC_SUBSITE}' does not exist, please provid a valid site"

  fi

  _BROWSER_SYNC_PLATFORM_PLATFORM_REPO=$(subscription_configuration_get_repository ${_BROWSER_SYNC_SUBSCRIPTION})
  _BROWSER_SYNC_PLATFORM_PLATFORM_REPO_NAME=$(git_extract_repository_name "${_BROWSER_SYNC_PLATFORM_PLATFORM_REPO}")
  _BROWSER_SYNC_PLATFORM_ACQUIA_BRANCH=$(subscription_configuration_get_plat_repo_resource ${_BROWSER_SYNC_SUBSCRIPTION})
  _BROWSER_SYNC_PLATFORM_ACQUIA_BRANCH_OUT=${_BROWSER_SYNC_PLATFORM_ACQUIA_BRANCH/\//-}
  _BROWSER_SYNC_PLATFORM_ACQUIA_BRANCH_OUT=${_BROWSER_SYNC_PLATFORM_ACQUIA_BRANCH_OUT^^}

  if [ -z ${_BROWSER_SYNC_PLATFORM_ACQUIA_BRANCH_OUT} ]; then

    raise RequiredParameterNotFound "[browser_sync_load_configurations] Please provide a valid site"

  fi

  if [ -z ${_BROWSER_SYNC_DOCKER_IMAGE} ]; then

    raise RequiredConfigNotFound "[browser_sync_load_configurations] Please configure variable _BROWSER_SYNC_DOCKER_IMAGE in configuration file [config/browser_sync_config.bash]"

  fi

}

function browser_sync_check_docker_image {

  out_warning "Checking image ${_BROWSER_SYNC_DOCKER_IMAGE}" 1

  if (docker_image_exists ${_BROWSER_SYNC_DOCKER_IMAGE}); then

    docker_image_pull ${_BROWSER_SYNC_DOCKER_IMAGE}
    out_check_status $? "Image ${_BROWSER_SYNC_DOCKER_IMAGE} downloaded" "Error while downloading ${_BROWSER_SYNC_DOCKER_IMAGE} image" 1

  fi

}

function browser_sync_execute() {

  local _BROWSER_SYNC_WORKING_THEME_CSS="${_BROWSER_SYNC_PROJECT_FOLDER}/web/${_BROWSER_SYNC_PLATFORM_ACQUIA_BRANCH_OUT}/docroot/sites/${_BROWSER_SYNC_SUBSITE_REAL_NAME}/themes/**/*.css"
  local _BROWSER_SYNC_SITE_THEME_CSS="${_BROWSER_SYNC_PROJECT_MAPPING_WEB_FOLDER}/${_BROWSER_SYNC_PLATFORM_ACQUIA_BRANCH_OUT}/docroot/sites/${_BROWSER_SYNC_SUBSITE_REAL_NAME}/themes/**/*.css"

  local _BROWSER_SYNC_WORKING_THEME_JS="${_BROWSER_SYNC_PROJECT_FOLDER}/web/${_BROWSER_SYNC_PLATFORM_ACQUIA_BRANCH_OUT}/docroot/sites/${_BROWSER_SYNC_SUBSITE_REAL_NAME}/themes/**/*.js"
  local _BROWSER_SYNC_SITE_THEME_JS="${_BROWSER_SYNC_PROJECT_MAPPING_WEB_FOLDER}/${_BROWSER_SYNC_PLATFORM_ACQUIA_BRANCH_OUT}/docroot/sites/${_BROWSER_SYNC_SUBSITE_REAL_NAME}/themes/**/*.js"


  local _BROWSER_SYNC_DOMAIN_LIST=$(site_configuration_get_domains ${_BROWSER_SYNC_SUBSCRIPTION} "local" ${_BROWSER_SYNC_SUBSITE})

  local _BROWSER_SYNC_PRIMARY_DOMAIN=$(echo "${_BROWSER_SYNC_DOMAIN_LIST}" | ${_SED} -e "s/\s/\n/g" | ${_GREP} "local$" | head -1)

  if [[ ${_BROWSER_SYNC_SITE_OS_WEB_PORT} != "80" ]]; then

    local _BROWSER_SYNC_PRIMARY_DOMAIN="${_BROWSER_SYNC_PRIMARY_DOMAIN}:${_BROWSER_SYNC_SITE_OS_WEB_PORT}"

  fi


  if [[ ! -z ${_BROWSER_SYNC_SITE_URL} ]]; then

    out_info "Modify default host to ${_BROWSER_SYNC_SITE_URL}"
    local _BROWSER_SYNC_PRIMARY_DOMAIN="${_BROWSER_SYNC_SITE_URL}"

  fi

  browser_sync_stop_container
  out_warning "Starting container ${_BROWSER_SYNC_CONTAINER}..." 1


  out_info "CSS watching: ${_BROWSER_SYNC_WORKING_THEME_CSS}" 1
  out_info "JS watching:  ${_BROWSER_SYNC_WORKING_THEME_JS}"

  local _EXTERNAL_IP=$(get_ip)
  echo -e "\n\t${BIPURPLE} External access: http://${_EXTERNAL_IP}:${_BROWSER_SYNC_SITE_PORT} ${COLOR_OFF}"
  echo -e "\t${BIPURPLE} UI External access: http://${_EXTERNAL_IP}:${_BROWSER_SYNC_ADMIN_PORT} ${COLOR_OFF}\n"

  docker_run --tty --rm \
    --publish ${_BROWSER_SYNC_SITE_PORT}:3000 \
    --publish ${_BROWSER_SYNC_ADMIN_PORT}:3001 \
    --net config_default \
    --volume=${_BROWSER_SYNC_PROJECT_FOLDER}:${_BROWSER_SYNC_PROJECT_MAPPING_FOLDER} \
    --volume=/etc/hosts:/etc/hosts \
    --hostname ${_BROWSER_SYNC_CONTAINER} \
    --name ${_BROWSER_SYNC_CONTAINER} \
    ${_BROWSER_SYNC_DOCKER_IMAGE} \
    start --proxy "${_BROWSER_SYNC_PRIMARY_DOMAIN}" \
    --files "${_BROWSER_SYNC_SITE_THEME_CSS}" \
    --files "${_BROWSER_SYNC_SITE_THEME_JS}"

}
