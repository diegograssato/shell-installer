#!/usr/bin/env


function system_update_260() {

  system_add_docker_compose_in_home_bash
  system_add_docker_install_ssh_depencies

}

function system_add_docker_compose_in_home_bash() {

  [[ "${SHELL}" == *"/bin/zsh" ]] && local _RC_FILE="$HOME/.zshrc"
  [[ "${SHELL}" == *"/bin/bash" ]] && local _RC_FILE="$HOME/.bashrc"

  if ! grep -wq "COMPOSE_FILE" ${_RC_FILE} ; then

    local _DOCKER_COMPOSER="${SF_SCRIPTS_HOME}/config/docker-compose.yml"
    echo "export COMPOSE_FILE=${_DOCKER_COMPOSER}" >> ${_RC_FILE}

  fi

}

function system_add_docker_install_ssh_depencies() {

  local SSH_PASS="sshpass"

  if [ $(program_is_installed ${SSH_PASS}) == 1 ]; then

    if (is_mac); then

      local SSH_PASS="https://raw.githubusercontent.com/kadwanev/bigboybrew/master/Library/Formula/sshpass.rb"

    fi

    install_software ${SSH_PASS}

  fi

}
