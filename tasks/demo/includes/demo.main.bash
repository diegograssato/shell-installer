#!/usr/bin/env bash

function demo_load_configurations {

  out_warning "Loading parameters configurations"

  _DEMO_PARAM=${1:-}
  validate_is_empty ${_DEMO_PARAM} "<parameter_name>" "demo_load_configurations"

  _DEMO_SUCCESS=${2:-"true"}
  validate_boolean ${_DEMO_SUCCESS} "success" "demo_load_configurations"

}

function demo_execute {

  out_warning "Starting execution"

  if [ ${_DEMO_SUCCESS} == "true" ]; then

    hello_world_success

  else

    hello_world_danger

  fi

  out_info "The given parameter is: ${_DEMO_PARAM}"

}
