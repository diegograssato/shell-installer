#!/usr/bin/env bash

# if executed in other local, ex,: create new applications

# name, dir
_SHELL_INSTALLER_NAME="${1}"
_SHELL_INSTALLER_DIR="${2}"
_SHELL_INSTALLER_REPO="https://github.com/diegograssato/shell-installer"
_SHELL_INSTALLER_BRANCH="framework"
_SHELL_INSTALLER_HOME="${HOME}/.sf"
_SHELL_INSTALLER_CONFIGURATION="${_SHELL_INSTALLER_HOME}/spry_framework.conf"
_SHELL_INSTALLER_PROJECTS="${_SHELL_INSTALLER_HOME}/projects"
_SHELL_INSTALLER_PROJECT_DIR="${_SHELL_INSTALLER_DIR}/${_SHELL_INSTALLER_NAME}"
_SHELL_INSTALLER_AUTLOAD="${_SHELL_INSTALLER_HOME}/spry_loader.sh"

[[ ! -d "${_SHELL_INSTALLER_HOME}" ]] && mkdir -p ${_SHELL_INSTALLER_HOME}
[[ ! -d "${_SHELL_INSTALLER_PROJECTS}" ]] && mkdir -p ${_SHELL_INSTALLER_PROJECTS}
[[ ! -d "${_SHELL_INSTALLER_HOME}" ]] && mkdir -p ${_SHELL_INSTALLER_HOME}
[[ ! -f "${_SHELL_INSTALLER_CONFIGURATION}" ]] && > ${_SHELL_INSTALLER_CONFIGURATION}

function _shell_installer_prepare_application() {


  echo -e "\n Preparing application....${_SHELL_INSTALLER_PROJECT_DIR}"

  [[ ! -d "${_SHELL_INSTALLER_PROJECT_DIR}" ]] && mkdir -p ${_SHELL_INSTALLER_PROJECT_DIR}
  [[ -d ${_SHELL_INSTALLER_PROJECT_DIR} ]] && rm -rf "${_SHELL_INSTALLER_PROJECT_DIR}/.git"

  #Remove this
  #[[ -d "${_SHELL_INSTALLER_PROJECT_DIR}" ]] && rm -rf ${_SHELL_INSTALLER_PROJECT_DIR}


  echo -e "\n**** Software installation directory: ${_SHELL_INSTALLER_PROJECT_DIR}"
  #git clone ${_SHELL_INSTALLER_REPO} ${_SHELL_INSTALLER_PROJECT_DIR} --depth 1
  #git -C ${_SHELL_INSTALLER_PROJECT_DIR} checkout ${_SHELL_INSTALLER_BRANCH}

cat <<EOF | tee "${_SHELL_INSTALLER_PROJECT_DIR}/autocomplete.sh"  > /dev/null 2>&1
#!/usr/bin/env bash
function spry_framework_autocomplete() {
  local cur prev
  COMPREPLY=()
  tasks=\$(find "${_SHELL_INSTALLER_PROJECT_DIR}/tasks" -type f -iname "*.sh" -not -iname ".*.sh" |egrep -o "\w+.sh$" | sed 's/\.sh//g');
  cur="\${COMP_WORDS[COMP_CWORD]}"
  COMPREPLY=( \$(compgen -W "\${tasks}" -- \${cur}) )

  return 0
}

complete -o nospace -F spry_framework_autocomplete ${_SHELL_INSTALLER_NAME}


EOF



}

function _shell_installer_prepare_skeleton() {

    echo -e "\n Prepare base skeleton: ${_SHELL_INSTALLER_PROJECT_DIR}"
    local _FOLDERS="tasks modules config"
    local _FILE_KEEP=".gitkeep"

    for _FOLDER in ${_FOLDERS[@]}; do

        mkdir -p "${_SHELL_INSTALLER_PROJECT_DIR}/${_FOLDER}"
        > "${_SHELL_INSTALLER_PROJECT_DIR}/${_FOLDER}/${_FILE_KEEP}"

    done

}

function _shell_installer_register_on_environment() {

    if( _shell_installer_check_already_configured_name && _shell_installer_check_already_configured_path ); then

        echo -e "\n Configure application in your environment."

        [[ ! -d "${_SHELL_INSTALLER_DIR}" ]] && mkdir -p ${_SHELL_INSTALLER_DIR}


        echo "${_SHELL_INSTALLER_NAME}#${_SHELL_INSTALLER_PROJECT_DIR}" >> ${_SHELL_INSTALLER_CONFIGURATION}
        _shell_installer_register_project_autload


    else

      echo -e "\n Project already installed: ${_SHELL_INSTALLER_PROJECT_DIR}"
      exit

    fi
}

function _shell_installer_register_project_autload() {


  if [ ! -f ${_SHELL_INSTALLER_AUTLOAD} ]; then

cat <<EOF | tee "${_SHELL_INSTALLER_AUTLOAD}"  > /dev/null 2>&1
#!/usr/bin/env bash

_SF_AUTOLOAD_PROJECTS_FILES=\$(find ${_SHELL_INSTALLER_PROJECTS} -name "*_rc.bash")

function projects_autoload() {

  local _FILE=""
  for _FILE in \$@; do

    if [ -n \${_FILE} ] && [ -f \${_FILE} ]; then

      source \${_FILE}

    fi

  done

}

projects_autoload "\${_SF_AUTOLOAD_PROJECTS_FILES}"

EOF



  fi

  if(! grep -qwo "### SPRY FRAMEWORK" "${HOME}/.bashrc"); then

cat <<EOF | tee -a "${HOME}/.bashrc"  > /dev/null 2>&1

### SPRY FRAMEWORK
source \${_SHELL_INSTALLER_AUTLOAD}

EOF

  fi

  cat <<EOF | tee "${_SHELL_INSTALLER_PROJECTS}/${_SHELL_INSTALLER_NAME}_rc.bash"  > /dev/null 2>&1
#!/usr/bin/env bash

# Alias of main script
alias ${_SHELL_INSTALLER_NAME}=${_SHELL_INSTALLER_PROJECT_DIR}/main.sh && SF_SCRIPTS_HOME=${_SHELL_INSTALLER_PROJECT_DIR} && _SCRIPTS_ALIAS=${_SHELL_INSTALLER_NAME}

# Load bash completion script
[[ "\${SHELL}" == *"/bin/zsh" ]] && _AUTOCOMPLETE_EXT="zsh"
[[ "\${SHELL}" == *"/bin/bash" ]] && _AUTOCOMPLETE_EXT="sh"
_AUTOCOMPLETE_FILE="${_SHELL_INSTALLER_PROJECT_DIR}/autocomplete.\${_AUTOCOMPLETE_EXT}"
[[ -x \${_AUTOCOMPLETE_FILE} ]] && source \${_AUTOCOMPLETE_FILE}

EOF

  chmod 777 "${_SHELL_INSTALLER_PROJECTS}/${_SHELL_INSTALLER_NAME}_rc.bash"
  chmod 777 ${_SHELL_INSTALLER_AUTLOAD}
}


function _shell_installer_check_already_configured_name() {

    local _SHELL_INSTALLER_CONFIGURATION_NAME=$(cat ${_SHELL_INSTALLER_CONFIGURATION} | cut -d"#" -f 1)
    if (echo  ${_SHELL_INSTALLER_CONFIGURATION_NAME} | sed "s# #\n#g" | egrep -qwo "^${_SHELL_INSTALLER_NAME}"); then

      return 1;

    fi

    return 0;

}

function _shell_installer_check_already_configured_path() {

    local _SHELL_INSTALLER_CONFIGURATION_NAME=$(cat ${_SHELL_INSTALLER_CONFIGURATION} | cut -d"#" -f 2)
    if (echo  ${_SHELL_INSTALLER_CONFIGURATION_NAME} | sed "s# #\n#g" | egrep -qwo "^${_SHELL_INSTALLER_DIR}$"); then

      return 1;

    fi

    return 0;


}

###############################################################################################

if [[ -z ${_SHELL_INSTALLER_NAME} ]]; then

  echo -e "\n Please enter a program name."

fi

if [[ -z ${_SHELL_INSTALLER_DIR} ]]; then

  echo -e "\n Please enter a program path."

fi

# Principal function
if [[ -d ${_SHELL_INSTALLER_DIR} ]]; then

  _shell_installer_register_on_environment
  _shell_installer_prepare_application
  _shell_installer_prepare_skeleton

fi
