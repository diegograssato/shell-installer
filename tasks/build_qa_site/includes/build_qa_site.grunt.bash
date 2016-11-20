#!/usr/bin/env bash

function build_qa_site_compile_grunt() {

  if [ -z ${1:-} ]; then

    raise RequiredParameterNotFound "[build_qa_site_compile_grunt] Please provide a valid site"

  else

    local _BUILD_QA_SITE_SUBSITE=${1}

  fi

  if [ -z ${2:-} ]; then

    raise RequiredParameterNotFound "[build_qa_site_compile_grunt] Please provide a valid subscription"

  else

    local _BUILD_QA_SITE_SUBSCRIPTION=${2}

  fi

  out_warning "Running grunt on ${_BUILD_QA_SITE_APACHE_SUBSITE_PATH}" 1

  build_qa_site_get_active_theme_path ${_BUILD_QA_SITE_APACHE_SUBSITE_PATH}

}

function build_qa_site_get_active_theme_path() {

  if [ -z ${1:-} ]; then

    raise RequiredParameterNotFound "[build_qa_site_get_active_theme_path] Please provide a valid subsite path"

  else

    local _BUILD_QA_SITE_SUBSITE_PATH=${1}

  fi

  ${_CD} ${_BUILD_QA_SITE_SUBSITE_PATH}

  local _ACTIVE_THEME=$(drush_vget theme_default "vget theme_default")

  local _QUERY="SELECT filename FROM system WHERE name='${_ACTIVE_THEME}'"
  # TODO implement drush sqlq function
  local _THEME_INFO_PATH=$(${_DRUSH} sqlq "${_QUERY}")
  local _THEME_PATH=$(echo ${_THEME_INFO_PATH} | sed "s/filename //g" | sed "s#/${_ACTIVE_THEME}\.info##g")

  if [ ! -z ${_THEME_PATH} ]; then

    _FULL_PATH_THEME="${_BUILD_QA_SITE_SUBSCRIPTION}/docroot/${_THEME_PATH}"
    os_grunt_run_task_full_path ${_FULL_PATH_THEME} ${_BUILD_QA_SITE_DOCKER_CONTAINER} && true
    if [ $? -ge 1 ]; then

      out_danger "Grunt in ${_FULL_PATH_THEME} was aborted. Please check the site theme."

    else

      out_success "Grunt executed successfully."

    fi

  else

    out_danger "Invalid theme path provided."

  fi
  # grunt_check_valid_path ${_FULL_PATH_THEME}
  # if [ $? -eq 0 ]; then
  #
  #   grunt_npm_install ${_FULL_PATH_THEME}
  #
  #   grunt_bundle_update ${_FULL_PATH_THEME}
  #
  #   grunt_run_grunt ${_FULL_PATH_THEME}
  #
  # fi

}
