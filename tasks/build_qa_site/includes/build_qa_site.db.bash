#!/usr/bin/env bash

function build_qa_site_update_configs() {

  out_info "Executing drush commands" 1

  drush_command vset file_temporary_path /tmp
  drush_command vset file_private_path /tmp

  drush_command vset autologout_enforce_admin 1
  drush_command vset autologout_timeout 1800
  drush_command vset autologout_padding 1800
  drush_command vset page_cache_maximum_age 86400
  drush_command vset cache_lifetime 0
  drush_command vset cache 1
  drush_command vset block_cache 1
  drush_command vset page_compression 1
  drush_command vset preprocess_css 1
  drush_command vset preprocess_js 1
  drush_command vset error_level 0

  drush_command en -y autologout dblog
  drush_command dis -y memcache memcache_admin syslog

}

function build_qa_site_update_multilanguage() {

  local _BUILD_QA_SITE_SUBSITE=${1:-}
  out_info "Checking if site is multilanguage" 1

  if (site_configuration_is_subsite_multi_language ${_BUILD_QA_SITE_SUBSITE} ${_BUILD_QA_SITE_SUBSCRIPTION}); then

    if [ $? -eq 0 ]; then

      local _SUBSITE_LANGUAGE_LIST=$(site_configuration_get_subsite_languages  ${_BUILD_QA_SITE_SUBSITE} ${_BUILD_QA_SITE_SUBSCRIPTION})

      for _LANGUAGE in ${_SUBSITE_LANGUAGE_LIST}; do

        local _DOMAIN_LIST=$(site_configuration_get_subsite_qa_domains ${_BUILD_QA_SITE_SUBSITE} ${_BUILD_QA_SITE_SUBSCRIPTION} ${_LANGUAGE})
        local _DOMAIN_LIST_FORMATED_FOR_UPDATE=$(echo ${_DOMAIN_LIST} | sed "s/ /,/g")

        drush_add_language_domains ${_LANGUAGE} "${_DOMAIN_LIST_FORMATED_FOR_UPDATE}"

      done

      ${_DRUSH} xmlsitemap-rebuild

    fi

  fi

}
