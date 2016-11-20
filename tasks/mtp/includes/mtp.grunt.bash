#!/usr/bin/env bash

function mtp_run_grunt() {

  for _THEME in ${_MTP_AFFECTED_THEMES}; do

    if [ ${_MTP_INTERACTIVE} == true ]; then

      out_confirm "Do you want to run Grunt in theme [ ${_THEME} ] ?" 1 && true
      [[ $? -ge 1 ]] && continue;

    fi

    mtp_run_process_grunt "${_THEME}"

  done

}


function mtp_run_process_grunt {

  local _MTS_GRUNT_THEME_PATH="${_MTP_SUBSCRIPTION}/${_THEME}"
  local _MTP_FULL_THEME_PATH="acquia/${_MTS_GRUNT_THEME_PATH}"
  local _MTP_GRUNT_PARAMS=" -v"
  local _THEME=${1:-}

  out_info "Run grunt into ${_THEME}"
  os_grunt_run_task_full_path ${_MTP_FULL_THEME_PATH} ${_MTP_DOCKER_CONTAINER} "${_MTP_GRUNT_PARAMS}" && true
  if [ $? -ge 1 ]; then

    if [ ${_MTP_INTERACTIVE} == true ]; then

      out_confirm "A grunt error occurred. Please run manually and continue [ ${_MTP_FULL_THEME_PATH} ]. Continue?" 1 && true
      if [ $? -ge 1 ]; then

        out_danger "Grunt error not solved. Aborting."

      else

        out_danger "Grunt in ${_MTP_FULL_THEME_PATH} was aborted. Please check manually."

      fi

    else

      mtp_abort "GruntError" "Grunt in ${_MTP_FULL_THEME_PATH} was aborted. Please check manually."

    fi

  else

    git_commit_all ${_MTP_ACQUIA_SUBSCRIPTION_PATH} "[GRUNT] ${_MTS_GRUNT_THEME_PATH}"

  fi


}
