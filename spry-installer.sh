#!/usr/bin/env bash

_SPRY_INSTALLER_NAME="${1}"
_SPRY_INSTALLER_DIR="${2}"
_SPRY_INSTALLER_REPO="git@bitbucket.org:ciandt_it/spry_framework.git"
_SPRY_INSTALLER_BRANCH="master"
_SPRY_INSTALLER_HOME="${HOME}/.spry"
_SPRY_INSTALLER_CONFIGURATION="${_SPRY_INSTALLER_HOME}/spry_framework.conf"
_SPRY_INSTALLER_PROJECTS="${_SPRY_INSTALLER_HOME}/projects"
_SPRY_INSTALLER_PROJECT_DIR="${_SPRY_INSTALLER_DIR}/${_SPRY_INSTALLER_NAME}"
_SPRY_INSTALLER_AUTLOAD="${_SPRY_INSTALLER_HOME}/spry_loader.sh"

[[ ! -d "${_SPRY_INSTALLER_HOME}" ]] && mkdir -p ${_SPRY_INSTALLER_HOME}
[[ ! -d "${_SPRY_INSTALLER_PROJECTS}" ]] && mkdir -p ${_SPRY_INSTALLER_PROJECTS}
[[ ! -f "${_SPRY_INSTALLER_CONFIGURATION}" ]] && > ${_SPRY_INSTALLER_CONFIGURATION}

[[ "${SHELL}" == *"/bin/zsh" ]] && _SPRY_INSTALLER_SHELL_HOME="${HOME}/.zshrc"
[[ "${SHELL}" == *"/bin/bash" ]] && _SPRY_INSTALLER_SHELL_HOME="${HOME}/.bashrc"
[[ ! -f "${_SPRY_INSTALLER_SHELL_HOME}" ]] && > ${_SPRY_INSTALLER_SHELL_HOME}

#Reset
COLOR_OFF='\033[0m'       # Text Reset
# Bold
BBLACK='\033[1;30m'       # Black
BRED='\033[1;31m'         # Red
BGREEN='\033[1;32m'       # Green
BYELLOW='\033[1;33m'      # Yellow
BBLUE='\033[1;34m'        # Blue
BPURPLE='\033[1;35m'      # Purple
BCYAN='\033[1;36m'        # Cyan
BWHITE='\033[1;37m'       # White

function spry_info() {

  local _LINE_BREAK=""
  [ ${#} -ge 2 ] && [ ${2} -eq 1 ] && _LINE_BREAK="\n"

  printf "${_LINE_BREAK}${BBLUE}[$(date +%H:%M:%S)][ * ] $1 ${COLOR_OFF}\n"

}

function spry_success() {

  local _LINE_BREAK=""
  [ ${#} -ge 2 ] && [ ${2} -eq 1 ] && _LINE_BREAK="\n"

  printf "${_LINE_BREAK}${BGREEN}[$(date +%H:%M:%S)][ ✔ ] $1 ${COLOR_OFF}\n"

}

function spry_danger() {

  local _LINE_BREAK=""
  [ ${#} -ge 2 ] && [ ${2} -eq 1 ] && _LINE_BREAK="\n"

  printf "${_LINE_BREAK}${BRED}[$(date +%H:%M:%S)][ ✘ ] $1 ${COLOR_OFF}\n"


}

function spry_warning() {

  local _LINE_BREAK=""
  [ ${#} -ge 2 ] && [ ${2} -eq 1 ] && _LINE_BREAK="\n"

  printf "${_LINE_BREAK}${BYELLOW}[$(date +%H:%M:%S)][ ! ] $1 ${COLOR_OFF}\n"

}


function spry_check_status() {

  _LINE_BREAK=""
  [ ${#} -ge 4 ] && [ ${4} -eq 1 ] && _LINE_BREAK="\n"

  _STATUS_CODE=${1}

  [ ${_STATUS_CODE} -eq 0 ] && spry_success "$2" && return 0
  [ ${_STATUS_CODE} -ne 0 ] && spry_danger "$3" && return 0

}

function _spry_installer_welcome() {

  clear
  spry_success "Welcome to Spry Framework - Symplifying your DevOps shell scripts development"
  spry_info "Do you have a git repository with an existing Spry project? [Y/n]"
  read _SPRY_INSTALLER_OPTION
  if [[ ${_SPRY_INSTALLER_OPTION} =~ ([Yy]) ]]; then

    _spry_installer_start_configuration

  elif [[ ${_SPRY_INSTALLER_OPTION} =~ ([Nn]) ]]; then

    _spry_installer_start_new_project

  else

   echo "Porra véi eh Y/y ou N/n"


   fi

  exit

}

function _spry_installer_start_configuration() {

  spry_info "Please enter git URL:"
  #read _SPRY_INSTALLER_REPO
  _SPRY_INSTALLER_REPO="https://github.com/diegograssato/shell-installer"

  [[ -z ${_SPRY_INSTALLER_REPO} ]] && _spry_installer_start_configuration

  spry_info "Please enter git branch [master]:"
  #read _SPRY_INSTALLER_BRANCH
  _SPRY_INSTALLER_BRANCH="opensolutions"

  spry_info "Please enter where the project will be placed. If empty I'll save here [$PWD]:"
  #read _SPRY_INSTALLER_DIR_TMP
  _SPRY_INSTALLER_DIR_TMP="/tmp/projects"

  [[ -z ${_SPRY_INSTALLER_BRANCH} ]] && _SPRY_INSTALLER_BRANCH='master'
  [[ -z ${_SPRY_INSTALLER_DIR_TMP} ]] && _SPRY_INSTALLER_DIR_TMP=$(pwd)

   _SPRY_INSTALLER_DIR=${_SPRY_INSTALLER_DIR_TMP}
   _SPRY_INSTALLER_NAME=$(basename ${_SPRY_INSTALLER_REPO})
   _SPRY_INSTALLER_PROJECT_DIR="${_SPRY_INSTALLER_DIR}/${_SPRY_INSTALLER_NAME}"
   _SPRY_INSTALLER_PROJECT_GIT_DIR="${_SPRY_INSTALLER_DIR}/${_SPRY_INSTALLER_NAME}"

  _spry_installer_load_repository
  _spry_installer_prepare_application
  _spry_installer_register_on_environment

  _spry_installer_prepare_autocomplete
  _spry_installer_end
  _spry_installer_install_dependencies

}


function _spry_installer_start_new_project() {


  echo "novo"

  [[ -d ${_SPRY_INSTALLER_PROJECT_DIR} ]] && rm -rf "${_SPRY_INSTALLER_PROJECT_DIR}/.git"
  spry_info "Please enter the project name."
  #read _SPRY_FRAMEWORK_PROJECT_NAME
  _SPRY_FRAMEWORK_PROJECT_NAME="dtux"

  spry_info "Please enter the project alias. [ ${_SPRY_FRAMEWORK_PROJECT_NAME} ]:"
  #read _SPRY_FRAMEWORK_PROJECT_ALIAS
  _SPRY_FRAMEWORK_PROJECT_ALIAS="dtux"

  spry_info "Please enter where the project will be placed. If empty I'll save here [$PWD]:"
  #read _SPRY_INSTALLER_DIR
  _SPRY_INSTALLER_DIR="/tmp/projects"

  [[ -z ${_SPRY_FRAMEWORK_PROJECT_NAME} ]] && _spry_installer_start_new_project
  [[ -z ${_SPRY_FRAMEWORK_PROJECT_ALIAS} ]] && _SPRY_FRAMEWORK_PROJECT_ALIAS=${_SPRY_FRAMEWORK_PROJECT_NAME}

  _SPRY_INSTALLER_NAME=${_SPRY_FRAMEWORK_PROJECT_NAME}
  _SPRY_INSTALLER_ALIAS=${_SPRY_FRAMEWORK_PROJECT_ALIAS}
  _SPRY_INSTALLER_PROJECT_GIT_DIR="${_SPRY_INSTALLER_DIR}/${_SPRY_INSTALLER_NAME}"
  _SPRY_INSTALLER_PROJECT_DIR="${_SPRY_INSTALLER_DIR}/${_SPRY_INSTALLER_NAME}"

  if( _spry_installer_check_already_configured_name && _spry_installer_check_already_configured_path ); then

    _spry_installer_load_repository
    _spry_installer_register_on_environment
    _spry_installer_prepare_autocomplete
    _spry_installer_end
    _spry_installer_install_dependencies

  else

    spry_danger "Project exists. [ ${_SPRY_INSTALLER_PROJECT_GIT_DIR} ]"
    exit 10;

  fi
#
#    _spry_installer_load_repository
#  _spry_installer_prepare_application
#  _spry_installer_register_on_environment
#
#  _spry_installer_prepare_autocomplete
#  _spry_installer_end
#  _spry_installer_install_dependencies

}

function _spry_installer_load_repository() {


  [[ ! -d "${_SPRY_INSTALLER_DIR}" ]] && mkdir -p ${_SPRY_INSTALLER_DIR}

  spry_info "Dowloading git repository. [ ${_SPRY_INSTALLER_PROJECT_DIR} ]"

  if [[ -d ${_SPRY_INSTALLER_PROJECT_GIT_DIR} ]]; then

      spry_danger "Project exists. [ ${_SPRY_INSTALLER_PROJECT_GIT_DIR} ]"
      _spry_installer_project_rollback_clean

  fi

  git clone ${_SPRY_INSTALLER_REPO} ${_SPRY_INSTALLER_PROJECT_GIT_DIR} -b ${_SPRY_INSTALLER_BRANCH} --depth 1
  local _SPRY_INSTALLER_CLONE_STATUS=$?

  spry_check_status ${_SPRY_INSTALLER_CLONE_STATUS} "Clone repository successfully." "Error while clone the repository."
  if [[ ${_SPRY_INSTALLER_CLONE_STATUS} -ge 1 ]]; then

      exit;

  fi

}


function _spry_installer_prepare_autocomplete() {

  [[ "${SHELL}" == *"/bin/zsh" ]] && _spry_installer_prepare_zsh_autocomplete
  [[ "${SHELL}" == *"/bin/bash" ]] && _spry_installer_prepare_bash_autocomplete

}

function _spry_installer_prepare_bash_autocomplete() {

  spry_info "Configure project bash autocomplete"

  cat <<EOF | tee "${_SPRY_INSTALLER_PROJECTS}/${_SPRY_INSTALLER_NAME}_rc.bash"  > /dev/null 2>&1
#!/usr/bin/env bash

# Alias of main script
alias ${_SPRY_FRAMEWORK_PROJECT_ALIAS}=${_SPRY_INSTALLER_PROJECT_DIR}/main.sh && _SCRIPT_HOME=${_SPRY_INSTALLER_PROJECT_DIR} && _SCRIPT_ALIAS=${_SPRY_FRAMEWORK_PROJECT_ALIAS}

function _spry_framework_autocomplete() {
  local cur prev
  COMPREPLY=()
  tasks=\$(find "${_SPRY_INSTALLER_PROJECT_DIR}/tasks" -type f -iname "*.sh" -not -iname ".*.sh" |egrep -o "\w+.sh$" | sed 's/\.sh//g');
  cur="\${COMP_WORDS[COMP_CWORD]}"
  COMPREPLY=( \$(compgen -W "\${tasks}" -- \${cur}) )

  return 0
}

complete -o nospace -F _spry_framework_autocomplete ${_SPRY_FRAMEWORK_PROJECT_ALIAS}

EOF

  chmod 777 "${_SPRY_INSTALLER_PROJECTS}/${_SPRY_INSTALLER_NAME}_rc.bash"

}

function _spry_installer_prepare_zsh_autocomplete() {

  spry_info "Configure project zsh autocomplete"

  cat <<EOF | tee "${_SPRY_INSTALLER_PROJECTS}/${_SPRY_INSTALLER_NAME}_rc.bash"  > /dev/null 2>&1
alias ${_SPRY_FRAMEWORK_PROJECT_ALIAS}=${_SPRY_INSTALLER_PROJECT_DIR}/main.sh && _SCRIPT_HOME=${_SPRY_INSTALLER_PROJECT_DIR} && _SCRIPT_ALIAS=${_SPRY_FRAMEWORK_PROJECT_ALIAS}

function _spry_framework_autocomplete() {

  find "${_SPRY_INSTALLER_PROJECT_DIR}/tasks" -type f -iname "*.sh" -not -iname ".*.sh" |egrep -o "\w+.sh$" | sed 's/\.sh//g'

}

_spry_framework_complete () {

  compadd \$(_spry_framework_autocomplete)

}

compdef _spry_framework_complete ${_SPRY_INSTALLER_PROJECT_DIR}/main.sh

EOF

  chmod 777 "${_SPRY_INSTALLER_PROJECTS}/${_SPRY_INSTALLER_NAME}_rc.bash"

}


function _spry_installer_prepare_application() {

  spry_info "Preparing application. [ ${_SPRY_INSTALLER_PROJECT_DIR} ]"

  _SPRY_INSTALLER_NAME_RC="${_SPRY_INSTALLER_PROJECTS}/${_SPRY_INSTALLER_NAME}_rc.bash"

  if [[ -f "${_SPRY_INSTALLER_PROJECT_DIR}/.env" ]]; then

    source "${_SPRY_INSTALLER_PROJECT_DIR}/.env"
    _SPRY_INSTALLER_NAME=${_SPRY_FRAMEWORK_PROJECT_NAME}
    _SPRY_INSTALLER_ALIAS=${_SPRY_FRAMEWORK_PROJECT_ALIAS}

    spry_info "Loading project name from project environment file. [ ${_SPRY_INSTALLER_NAME} ]"
    spry_info "Loading project alias from project environment file. [ ${_SPRY_FRAMEWORK_PROJECT_ALIAS} ]"

  else

   spry_info "Please enter the project name. [ ${_SPRY_INSTALLER_NAME} ]:"
   read _SPRY_FRAMEWORK_PROJECT_NAME

   spry_info "Please enter the project alias. [ ${_SPRY_INSTALLER_NAME} ]:"
   read _SPRY_FRAMEWORK_PROJECT_ALIAS


    [[ -z ${_SPRY_FRAMEWORK_PROJECT_NAME} ]] && _SPRY_FRAMEWORK_PROJECT_NAME=${_SPRY_INSTALLER_NAME}
    [[ -z ${_SPRY_FRAMEWORK_PROJECT_ALIAS} ]] && _SPRY_FRAMEWORK_PROJECT_ALIAS=${_SPRY_INSTALLER_NAME}
    [[ -z ${_SPRY_INSTALLER_ALIAS} ]] && _SPRY_INSTALLER_ALIAS=${_SPRY_FRAMEWORK_PROJECT_ALIAS}

    _spry_installer_create_project_env

  fi

  _SPRY_INSTALLER_PROJECT_DIR_TMP="${_SPRY_INSTALLER_DIR}/${_SPRY_INSTALLER_NAME}"

  if [[ -d ${_SPRY_INSTALLER_PROJECT_DIR_TMP} ]]; then

      spry_danger "Project exists. [ ${_SPRY_INSTALLER_PROJECT_DIR_TMP} ]"
      _spry_installer_project_rollback_clean

   fi

  # Move git name to real project real name
  if [[ "${_SPRY_INSTALLER_PROJECT_DIR}" != "${_SPRY_INSTALLER_PROJECT_DIR_TMP}" ]]; then

    mv ${_SPRY_INSTALLER_PROJECT_DIR} "${_SPRY_INSTALLER_PROJECT_DIR_TMP}"
    _SPRY_INSTALLER_PROJECT_DIR="${_SPRY_INSTALLER_DIR}/${_SPRY_INSTALLER_NAME}"

  fi

}
function _spry_installer_create_project_env() {

  spry_info "Create project contiguration file ${_SPRY_INSTALLER_PROJECT_DIR}/.env"
  cat <<EOF | tee "${_SPRY_INSTALLER_PROJECT_DIR}/.env"  > /dev/null 2>&1
_SPRY_FRAMEWORK_PROJECT_NAME="${_SPRY_INSTALLER_NAME}"
_SPRY_FRAMEWORK_PROJECT_ALIAS="${_SPRY_INSTALLER_ALIAS}"

EOF


}


function _spry_installer_register_on_environment() {

  if( _spry_installer_check_already_configured_name && _spry_installer_check_already_configured_path ); then

    spry_info "Configure application in your environment."

    [[ ! -d "${_SPRY_INSTALLER_DIR}" ]] && mkdir -p ${_SPRY_INSTALLER_DIR}

    echo "${_SPRY_INSTALLER_NAME}#${_SPRY_INSTALLER_PROJECT_DIR}" >> ${_SPRY_INSTALLER_CONFIGURATION}
    _spry_installer_register_project_autload


  else

    spry_danger "Project already installed. [ ${_SPRY_INSTALLER_PROJECT_DIR} ]"
    _spry_installer_project_rollback_clean

  fi

}

function _spry_installer_project_rollback_clean() {

  spry_info "Rollbacking instalation. [ ${_SPRY_INSTALLER_PROJECT_GIT_DIR} ]"
  [[ -d "${_SPRY_INSTALLER_PROJECT_GIT_DIR}" ]] && spry_info "Remove git repository path. [ ${_SPRY_INSTALLER_PROJECT_GIT_DIR} ]" && rm -rf ${_SPRY_INSTALLER_PROJECT_GIT_DIR}

  exit

}

function _spry_installer_register_project_autload() {


  if [ ! -f ${_SPRY_INSTALLER_AUTLOAD} ]; then

cat <<EOF | tee "${_SPRY_INSTALLER_AUTLOAD}"  > /dev/null 2>&1
#!/usr/bin/env bash

_SPRY_AUTOLOAD_PROJECTS_FILES=\$(find ${_SPRY_INSTALLER_PROJECTS} -name "*_rc.bash")

function projects_autoload() {

  local _FILE=""
  for _FILE in \$@; do

    if [ -n \${_FILE} ] && [ -f \${_FILE} ]; then

      source \${_FILE}

    fi

  done

}

projects_autoload "\${_SPRY_AUTOLOAD_PROJECTS_FILES}"

EOF

  fi

  if(! grep -qwo "### SPRY FRAMEWORK ###" "${_SPRY_INSTALLER_SHELL_HOME}"); then

cat <<EOF | tee -a "${_SPRY_INSTALLER_SHELL_HOME}"  > /dev/null 2>&1

### SPRY FRAMEWORK ###
if [ -x ${_SPRY_INSTALLER_AUTLOAD} ]; then

  source ${_SPRY_INSTALLER_AUTLOAD}

fi

EOF

  fi

  chmod 777 ${_SPRY_INSTALLER_AUTLOAD}

}

function _spry_installer_install_dependencies() {

  spry_info "Installing project dependencies."
  echo [ ${_SPRY_INSTALLER_PROJECT_DIR} ]

}

function _spry_installer_end() {

  spry_success "Project installed succefully."
  spry_info "Instalation path. [ ${_SPRY_INSTALLER_PROJECT_DIR} ]"
  spry_info "Run [ source ${_SPRY_INSTALLER_SHELL_HOME} ] command to reload environment"
  spry_info "Project name. [ ${_SPRY_INSTALLER_NAME} ]"
  spry_info "Project alias. [ ${_SPRY_INSTALLER_ALIAS} ]"
  spry_info "Run ${_SPRY_INSTALLER_ALIAS} [SPACE] [TAB] to see all tasks."

}

function _spry_installer_check_already_configured_name() {

    local _SPRY_INSTALLER_CONFIGURATION_NAME=$(cat ${_SPRY_INSTALLER_CONFIGURATION} | cut -d"#" -f 1)
    if (echo  ${_SPRY_INSTALLER_CONFIGURATION_NAME} | sed "s# #\n#g" | egrep -qwo "^${_SPRY_INSTALLER_NAME}"); then

      return 1;

    fi

    return 0;

}

function _spry_installer_check_already_configured_path() {

    local _SPRY_INSTALLER_CONFIGURATION_NAME=$(cat ${_SPRY_INSTALLER_CONFIGURATION} | cut -d"#" -f 2)
    if (echo  ${_SPRY_INSTALLER_CONFIGURATION_NAME} | sed "s# #\n#g" | egrep -qwo "^${_SPRY_INSTALLER_DIR}$"); then

      return 1;

    fi

    return 0;
}

###############################################################################################
_spry_installer_welcome
