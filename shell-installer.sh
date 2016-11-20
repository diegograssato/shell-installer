#!/usr/bin/env bash


# if executed in application directory



# if executed in other local, ex,: create new applications

# name, dir
_SHELL_INSTALLER_NAME="${1}"
_SHELL_INSTALLER_DIR="${2}"
_SHELL_INSTALLER_REPO="https://github.com/diegograssato/shell-installer"
_SHELL_INSTALLER_BRANCH="framework"
_SHELL_INSTALLER_CONFIGURATION="shell-installer.bash"

function _shell_installer_prepare_application() {

  echo -e "\nPreparin application...."
  [[ -d ${_SHELL_INSTALLER_DIR} ]] && rm -rf "${_SHELL_INSTALLER_DIR}/.git"

  cp ${_SHELL_INSTALLER_CONFIGURATION} ${_SHELL_INSTALLER_DIR}

  if [[ ! -f "${_SHELL_INSTALLER_DIR}/${_SHELL_INSTALLER_CONFIGURATION}" ]]; then

    echo -e "\n Configuration file blah"
    exit 1;

  fi

  source ${_SHELL_INSTALLER_CONFIGURATION}

  for DEPENDECIES in ${_SHELL_INSTALLER_DEPENDECIES[@]}; do

    DEPENDENCY=$(echo ${DEPENDECIES} |cut -d# -f 1)
    DEPENDENCY_NAME=$(basename ${DEPENDENCY})
    VERSION=$(echo ${DEPENDECIES} |cut -d# -f 2)
    TYPE=$(echo ${DEPENDECIES} |cut -d# -f 3)

    [[ -d "/tmp/${TYPE}" ]] && rm -rf "/tmp/${TYPE}"
    git clone ${DEPENDENCY} "/tmp/${TYPE}"
    git -C "/tmp/${TYPE}" checkout ${VERSION}

    if [[ ${TYPE} == "tasks" ]]; then

      [[ ! -d "${_SHELL_INSTALLER_DIR}/tasks" ]] && mkdir -p "${_SHELL_INSTALLER_DIR}/tasks"
      rm -rf "/tmp/${TYPE}/.git"
      cp -r "/tmp/${TYPE}/." "${_SHELL_INSTALLER_DIR}/tasks"
      rm -rf "/tmp/${TYPE}"

    fi

    if [[ ${TYPE} == "modules" ]]; then

      [[ ! -d "${_SHELL_INSTALLER_DIR}/modules" ]] && mkdir -p "${_SHELL_INSTALLER_DIR}/modules"
      rm -rf "/tmp/${TYPE}/.git"
      cp -r "/tmp/${TYPE}/." "${_SHELL_INSTALLER_DIR}/modules"
      rm -rf "/tmp/${TYPE}"

    fi


  done
}
###############################################################################################

if [[ -z ${_SHELL_INSTALLER_NAME} ]]; then

  echo -e "\n Please enter a program name:"

fi

if [[ -z ${_SHELL_INSTALLER_DIR} ]]; then

  echo -e "\n Please enter a program path:"

fi

_SHELL_INSTALLER_DIR="${_SHELL_INSTALLER_DIR}/${_SHELL_INSTALLER_NAME}"
[[ -d "${_SHELL_INSTALLER_DIR}" ]] && rm -rf ${_SHELL_INSTALLER_DIR}
[[ ! -d "${_SHELL_INSTALLER_DIR}" ]] && mkdir -p ${_SHELL_INSTALLER_DIR}

echo -e "\n Software installation directory: ${_SHELL_INSTALLER_DIR}"
git clone ${_SHELL_INSTALLER_REPO} ${_SHELL_INSTALLER_DIR}
git -C ${_SHELL_INSTALLER_DIR} checkout ${_SHELL_INSTALLER_BRANCH}

if [[ -d ${_SHELL_INSTALLER_DIR} ]]; then

  _shell_installer_prepare_application

fi
