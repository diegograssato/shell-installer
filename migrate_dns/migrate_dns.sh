#!/usr/bin/env bash

import acquia drush git

function migrate_dns_run() {

  # 1. Load basics configurations and validate parameters
  migrate_dns_load_configurations "${@}"

  # 2. Execute operation
  migrate_dns_exec

}

function migrate_dns_usage() {

  if [ ! ${#} -ge 4 ]; then

    out_usage "sf migrate_dns <add|del> <subscription> <environment> <domains>" 1
    return 1

  else

    return 0

  fi

}
