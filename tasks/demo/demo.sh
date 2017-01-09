#!/usr/bin/env bash

import hello_world

function demo_run() {

  demo_load_configurations "${@}"

  demo_execute

}

function demo_usage() {

  if [ ${#} -lt 1 ] || [ ${#} -gt 2 ]; then

    out_usage "${_SCRIPT_ALIAS} demo <param> (<success:true>)" 1
    return 1

  else

    return 0

  fi

}
