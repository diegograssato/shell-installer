#!/usr/bin/env bash

import docker yml_loader drush metrics cloudflare
import os_command site_configuration subscription_configuration

function reindex_run() {

  # 1. Load basics configurations and validate parameters
  reindex_load_configurations "${@}"
  reindex_metrics_init
  metrics_touch

  # 2. Execute reindex
  reindex_clear_cache
  metrics_touch

  # 3. Clear Varnish
  reindex_clear_varnish
  metrics_touch

  # 4. Clear Cloudflare CDN
  reindex_clear_cdn
  metrics_touch

}

function reindex_usage() {

  if [ ${#} -lt 3 ] || [ ${#} -gt 8  ] ; then

    out_usage "sf reindex <subscription> <environment> <subsite> (<solr>:true) (<sitemapxml>:true) (<bv>:false) (<cdn>:false) (<domain>)" 1
    return 1

  else

    return 0

  fi

}
