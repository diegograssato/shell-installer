#!/usr/bin/env bash

function mts_run_grunt() {

  for _THEME in ${_MTS_AFFECTED_THEMES}; do

    if [ ${_MTS_INTERACTIVE} == true ]; then

      out_confirm "Do you want to run Grunt in theme [ ${_THEME} ] ?" 1 && true
      [[ $? -ge 1 ]] && continue;

    fi

    mts_run_process_grunt "${_THEME}"

  done

}

function mts_run_process_grunt() {

  local _MTS_THEME=${1:-}

  local _MTS_GRUNT_THEME_PATH="docroot/sites/${_MTS_SUBSITE_NAME}/$(echo ${_MTS_THEME} | cut -d '/' -f2,3)"
  local _MTS_THEME_PATH="${_MTS_ACQUIA_SUBSCRIPTION_PATH}/${_MTS_GRUNT_THEME_PATH}"
  local _MTS_FULL_THEME_PATH="acquia/${_MTS_SUBSCRIPTION}/${_MTS_GRUNT_THEME_PATH}/"
  local _MTS_ACQUIA_THEME_PATH=$(echo ${_MTS_FULL_THEME_PATH} | sed "s#${HOME}##g")

  if [ -d "${_MTS_THEME_PATH}" ]; then

    out_info "Run grunt into ${_MTS_THEME}" 1

    local _MTS_SUBSITE_THEME_PATH=""

    os_grunt_run_task_full_path ${_MTS_ACQUIA_THEME_PATH} ${_MTS_DOCKER_CONTAINER} && true
    if [ $? -ge 1 ]; then

      if [ ${_MTS_INTERACTIVE} == true ]; then

        out_confirm "A grunt error occurred. Please run manually and continue. Continue?" 1 && true
        if [ $? -ge 1 ]; then

          mts_abort "GruntError" "Grunt error not solved. Aborting."

        fi

      else

        mts_abort "GruntError" "Grunt in ${_MTS_FULL_THEME_PATH} was aborted. Please check manually."

      fi

    else

      git_commit_all ${_MTS_ACQUIA_SUBSCRIPTION_PATH} "[GRUNT] ${_MTS_GRUNT_THEME_PATH}"

    fi

  else

    mts_abort "GruntError" "Invalid theme path provided. Grunt cannot be executed on ${_MTS_THEME_PATH}."

  fi

}
