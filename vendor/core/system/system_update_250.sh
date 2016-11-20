#!/usr/bin/env


function system_update_250() {

  system_install_linux_depencies
  system_install_mac_depencies

}

function system_install_mac_depencies() {

  if (is_mac); then

    update_system_repo
    if [ $(program_is_installed 'gnu-sed') == 1 ]; then

      ${_BREW} install gnu-sed --with-default-names

    fi

    if [ $(program_is_installed 'coreutils') == 1 ]; then

      install_software "coreutils"

    fi

    if [ -f /usr/local/bin/gtac ] && [ ! -f /usr/local/bin/tac​​ ]; then

      ${_LN} -s /usr/local/bin/gtac /usr/local/bin/tac​​

    fi

  fi

}

function system_install_linux_depencies() {

  if (is_linux); then

   update_system_repo
   install_software "drush parallel zip unzip git curl meld gitg vim mysql-client nfs-common mc jq"

   install_software "php-curl" && true ; install_software "php5-curl" && true

    if [ $(program_is_installed 'docker-engine') == 1 ]; then

      wget -qO- https://get.docker.com/ | sudo bash
      sudo usermod -aG docker $USER
      sudo chown $USER:docker /var/run/docker.sock

    fi

  fi

}
