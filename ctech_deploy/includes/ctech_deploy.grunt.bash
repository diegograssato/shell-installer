#!/usr/bin/env bash

function ctech_deploy_run_grunt() {

  if [ ! -z ${JENKINS_HOME+x} ]; then

    ctech_deploy_grunt_jenkins

  else

    ctech_deploy_grunt_local

  fi

}

function ctech_deploy_grunt_local() {

  for _THEME in ${_CTECH_DEPLOY_AFFECTED_THEMES}; do

    local _CTECH_DEPLOY_GRUNT_THEME_PATH="docroot/sites/${_CTECH_DEPLOY_SUBSITE_NAME}/$(echo ${_THEME} | cut -d '/' -f2,3)"
    local _CTECH_DEPLOY_FULL_THEME_PATH="${_CTECH_DEPLOY_ACQUIA_SUBSCRIPTION_PATH}/${_CTECH_DEPLOY_GRUNT_THEME_PATH}"
    local _CTECH_DEPLOY_ACQUIA_THEME_PATH=$(echo ${_CTECH_DEPLOY_FULL_THEME_PATH} | sed "s#${HOME}##g")

    if [ -d "${_CTECH_DEPLOY_FULL_THEME_PATH}" ]; then

      out_info "Run grunt into ${_THEME}" 1

      local _CTECH_DEPLOY_SUBSITE_THEME_PATH=""

      os_grunt_run_task_full_path ${_CTECH_DEPLOY_ACQUIA_THEME_PATH} ${_CTECH_DEPLOY_DOCKER_CONTAINER} && true
      if [ $? -ge 1 ]; then

        ctech_deploy_abort_script "GruntError" "Grunt in ${_CTECH_DEPLOY_FULL_THEME_PATH} was aborted. Please check manually."

      fi

      git_commit_all ${_CTECH_DEPLOY_ACQUIA_SUBSCRIPTION_PATH} "[GRUNT] ${_CTECH_DEPLOY_GRUNT_THEME_PATH}"

    else

      ctech_deploy_abort_script "GruntError" "Invalid theme path provided. Grunt cannot be executed on ${_CTECH_DEPLOY_FULL_THEME_PATH}."

    fi

  done

}

function ctech_deploy_grunt_jenkins() {

  # TODO: Implement Grunt from Jenkins
  out_warning "TODO: Jenkins" 1

}
