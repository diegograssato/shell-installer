#!/usr/bin/env bash

import janrain

function janrain_access_run() {

  # 1. Load basics configurations and validate parameters
  janrain_access_load_configurations "${@}"

  # 2. Load current user data and print
  janrain_access_fetch_user

  # 3. Update user record
  janrain_access_add_role

}

function janrain_access_usage() {

  if [ ! ${#} -eq 1 ] && [ ! ${#} -eq 3  ]; then

    out_usage "sf janrain_access <mail> (<janrain_entitlement:false>) (<role:false>)" 1
    return 1

  else

    return 0

  fi

}
