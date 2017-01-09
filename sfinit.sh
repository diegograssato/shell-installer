#!/usr/bin/env bash

_DIRNAME=$(dirname "$0")
_CURRENT_DIR=$(pwd)

if [ ! "${_DIRNAME}" == "." ]; then

  _CURRENT_DIR=${_CURRENT_DIR}/${_DIRNAME}

fi

_DOCKER_COMPOSER_DIST="${_CURRENT_DIR}/config/docker-compose.yml.dist"
_DOCKER_COMPOSER="${_CURRENT_DIR}/config/docker-compose.yml"

if [ ! -f ${_DOCKER_COMPOSER} ]; then

  cp -a ${_DOCKER_COMPOSER_DIST} ${_DOCKER_COMPOSER}
  echo -e "\nPlease configure the ports of containers: ${_DOCKER_COMPOSER}"

else

  echo -e "\nCheck docker configuration file in: ${_DOCKER_COMPOSER}"
  echo -e "Please check the ports of containers: ${_DOCKER_COMPOSER}"

fi

[[ "${SHELL}" == *"/bin/zsh" ]] && _RC_FILE="$HOME/.zshrc"
[[ "${SHELL}" == *"/bin/bash" ]] && _RC_FILE="$HOME/.bashrc"

grep -Fxwq "#SF_INIT_SCRIPT" ${_RC_FILE}

if [ $? -ge 1 ]; then

  echo -e "\n#SF_INIT_SCRIPT
export SF_SCRIPTS_HOME=${_CURRENT_DIR}
export COMPOSE_FILE=${_DOCKER_COMPOSER}
[ -f \${SF_SCRIPTS_HOME}/.sfrc ] && source \${SF_SCRIPTS_HOME}/.sfrc" >> ${_RC_FILE}

  echo -e "\nInstallation complete. Please reload the terminal"

else

  echo -e "\nSF init script was already present in ${_RC_FILE}"

fi
