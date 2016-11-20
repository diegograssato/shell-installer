#!/usr/bin/env bash

# TODO should contain only API functions on main file. Move all the others to
# a sub file

function grunt_check_valid_path() {

  if [ -z ${1:-} ]; then

    raise RequiredParameterNotFound "[grunt_check_valid_path] Please provide a valid site theme path"

  else

    local _FULL_PATH_THEME=${1}

  fi

	if [ -d ${_FULL_PATH_THEME} ] && [ -s "${_FULL_PATH_THEME}/package.json" ]; then

		if [ -d "${_FULL_PATH_THEME}/release" ]; then

			${_RMF} ${_FULL_PATH_THEME}/release

		fi

    if [ -d "${_FULL_PATH_THEME}/debug/styles/base-sass" ]; then

			${_RMF} ${_FULL_PATH_THEME}/debug/styles/base-sass

    fi

	else

    raise InvalidFolder "[grunt_check_valid_path] Folder not found: ${_FULL_PATH_THEME}";

	fi

}

function grunt_npm_install() {

  if [ -z ${1:-} ]; then

    raise RequiredParameterNotFound "[grunt_npm_install] Please provide a valid site theme path"

  else

    local _FULL_PATH_THEME=${1}

  fi

  if [ -d ${_FULL_PATH_THEME} ];then

    out_info "Running npm install" 1

    ${_CD} ${_FULL_PATH_THEME}
    ${_NPM} install;
    local _STATUS=$?
    out_check_status ${_STATUS} "NPM installed successfully" "Failed on NPM install";
    ${_CD} -
    return ${_STATUS}

  else

    raise InvalidFolder "[grunt_npm_install] Folder not found: ${_FULL_PATH_THEME}";

  fi

}

function grunt_bundle_update() {

  if [ -z ${1:-} ]; then

    raise RequiredParameterNotFound "[grunt_bundle_update] Please provide a valid site theme path"

  else

    local _FULL_PATH_THEME=${1}

  fi

  if [ -d ${_FULL_PATH_THEME} ];then

    out_info "Running bundle update" 1

    ${_CD} ${_FULL_PATH_THEME}
    ${_BUNDLE} install
    local _STATUS=$?
    out_check_status ${_STATUS} "Bundle updated successfully" "Failed on Bundle update";
    ${_CD} -
    return ${_STATUS}

  else

    raise InvalidFolder "[grunt_bundle_update] Folder not found: ${_FULL_PATH_THEME}";

  fi

}

function grunt_run_grunt() {

  if [ -z ${1:-} ]; then

    raise RequiredParameterNotFound "[grunt_run_grunt] Please provide a valid site theme path"

  else

    local _FULL_PATH_THEME=${1}

  fi

  if [ -d ${_FULL_PATH_THEME} ];then

    out_info "Running grunt" 1

    ${_CD} ${_FULL_PATH_THEME}
    ${_GRUNT}
    local _STATUS=$?
    out_check_status ${_STATUS} "Grunt executed successfully" "Failed on Grunt execution";
    ${_CD} -
    return ${_STATUS}

  else

    raise InvalidFolder "[grunt_run_grunt] Folder not found: ${_FULL_PATH_THEME}";

  fi

}
