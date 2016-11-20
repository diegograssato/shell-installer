#!/usr/bin/env bash

import acquia metrics

function domain_report_run() {

  # Load basics configurations and validate parameters
  domain_report_load_configurations "${@}"
  domain_report_init
  metrics_touch

  domain_report_get_domains
  metrics_touch

  domain_report_get_address
  metrics_touch

  domain_report_list
  metrics_touch

  domain_report_file
  metrics_touch

}

function domain_report_usage() {

  if [ ${#} -lt 2 ] || [ ${#} -gt 2 ]; then

    out_usage "sf domain_report <subscription> <environment>" 1
    return 1

  else

    return 0

  fi

}
