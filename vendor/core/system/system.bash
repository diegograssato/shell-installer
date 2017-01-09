#!/usr/bin/env bash

function system_check_packages() {

  if (is_linux); then

    echo " _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ "
    for _PROGRAM in ${_SF_SCRIPT_LINUX_DEPENDENCIES}; do

      echo "|$(out_if $(program_is_installed ${_PROGRAM}) "${_PROGRAM}")"
      echo "${_PROGRAM^^}=$(program_is_installed ${_PROGRAM}) " >> ${_SYSTEM_CONFIGURATION_FILE}
      echo "|_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _|"

    done

  fi

  if (is_mac); then

    echo " _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ "
    for _PROGRAM in ${_SF_SCRIPT_MAC_DEPENDENCIES}; do

      echo "|$(out_if $(program_is_installed ${_PROGRAM}) "${_PROGRAM}")"
      echo "${_PROGRAM^^}=$(program_is_installed ${_PROGRAM}) " >> ${_SYSTEM_CONFIGURATION_FILE}
      echo "|_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _|"

    done

  fi

}


function system_create_home() {

  _SYSTEM_CONFIGURATION_PATH="$HOME/.canvas_ops"
  _SYSTEM_CONFIGURATION_FILE="${_SYSTEM_CONFIGURATION_PATH}/canvas_ops.cfg"

  if [ ! -d "${_SYSTEM_CONFIGURATION_PATH}" ]; then

    filesystem_create_folder_777 ${_SYSTEM_CONFIGURATION_PATH}

  fi

  if [ ! -f ${_SYSTEM_CONFIGURATION_FILE} ]; then

    filesystem_create_file_777 ${_SYSTEM_CONFIGURATION_FILE}

  fi

}

function system_check_dependencies() {

  echo "VERSION=${_SF_SCRIPT_VERSION}" > ${_SYSTEM_CONFIGURATION_FILE}
  system_check_packages

}

function system_check_update() {

  system_create_home
  local _SCRIPT_VERSION_NEW=$(echo ${_SF_SCRIPT_VERSION^^} | sed 's/\W//g')
  local _SF_SCRIPT_VERSION_OLD=$(system_check_configurations 'VERSION')
  local _SF_SCRIPT_VERSION_OLD=$(echo ${_SF_SCRIPT_VERSION_OLD^^} | sed 's/\W//g')

  if [ ! "${_SCRIPT_VERSION_NEW}" == "${_SF_SCRIPT_VERSION_OLD}" ]; then

    system_check_old_updates
    system_check_dependencies

    local _VERSION;
    for (( _VERSION="${_SF_SCRIPT_VERSION_OLD}"; _VERSION <= "${_SCRIPT_VERSION_NEW}"; _VERSION++ )); do

      if (is_function? "system_update_${_VERSION}"); then

        out_warning "Applying system_update_${_VERSION} version" 1
        "system_update_${_VERSION}"

      fi

    done
  fi

}

function system_check_dependencies_not_installed() {

  if [ -f ${_SYSTEM_CONFIGURATION_FILE} ]; then

    local _SYSTEM_INSTALL_NOW=""
    if (is_linux); then

      for _PROGRAM in ${_SF_SCRIPT_LINUX_DEPENDENCIES}; do

        if [[ $(system_check_configurations ${_PROGRAM}) == 1 ]]; then

          out_danger "Please install ${_PROGRAM}"
          _SYSTEM_INSTALL_NOW="${_PROGRAM} ${_SYSTEM_INSTALL_NOW}"

        fi

      done

    fi

    if (is_mac); then

      for _PROGRAM in ${_SF_SCRIPT_MAC_DEPENDENCIES}; do

        if [[ $(system_check_configurations ${_PROGRAM}) == 1 ]]; then

          out_danger "Please install ${_PROGRAM}"
          _SYSTEM_INSTALL_NOW="${_PROGRAM} ${_SYSTEM_INSTALL_NOW}"

        fi

      done

    fi

    if [[ -n ${_SYSTEM_INSTALL_NOW} ]]; then

      out_info "Tring to install software"
      install_software ${_SYSTEM_INSTALL_NOW}
      system_check_dependencies

    fi

  fi

}

function system_check_old_updates() {

  for _LAST_VERSIONS in ${_SF_SCRIPT_LAST_VERSIONS}; do

    local _LAST_VERSIONS=$(echo ${_LAST_VERSIONS^^} | sed 's/\W//g')
    if (is_function? "system_update_${_LAST_VERSIONS}"); then

      out_warning "Applying ${_LAST_VERSIONS} update version" 1
      "system_update_${_LAST_VERSIONS}"

    fi

  done

}

function system_check_configurations() {

  local _SYSTEM_CONFIGURATION=${1^^}
  local _SYSTEM_VERSION=$(sed -n -e "/${_SYSTEM_CONFIGURATION}/{s/.*=//p}" ${_SYSTEM_CONFIGURATION_FILE})
  echo ${_SYSTEM_VERSION}

}
