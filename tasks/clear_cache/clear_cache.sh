#!/usr/bin/env bash

import docker yml_loader drush metrics cloudflare
import os_command site_configuration subscription_configuration

function clear_cache_run() {

  # 1. Load basics configurations and validate parameters
  clear_cache_load_configurations "${@}"
  clear_cache_init
  metrics_touch

  # 2. Execute clear drupal cache
  clear_cache_drupal
  metrics_touch

  # 3. Execute clear memcache cache
  clear_cache_memcache
  metrics_touch

  # 4. Execute clear varnish cache
  clear_cache_varnish
  metrics_touch

  # 4. Execute clear CDN cache
  clear_cache_cdn
  metrics_touch

}

function clear_cache_usage() {

  if [ ${#} -lt 3 ] || [ ${#} -gt 7  ] ; then

    out_usage "sf clear_cache <subscription> <environment> <subsite> (<drupal_cache>:true) (<memcache:true>) (<varnish:true>) (<cdn:false>)" 1
    return 1

  else

    return 0

  fi

}
