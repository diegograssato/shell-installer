#!/usr/bin/env bash

function subs_info_get_live_sites() {

  local _SUBS_INFO_SUBSCRIPTION=${1:-}
  local _SUBS_INFO_ENV="prod"

  local _SUBSCRIPTION_PROD_URLS=$(drush_ac_domain_list ${_SUBS_INFO_SUBSCRIPTION} ${_SUBS_INFO_ENV})

  local _SUB_SITES=$(drush_get_subsites_from_acquia ${_SUBS_INFO_SUBSCRIPTION} ${_SUBS_INFO_ENV})

  out_info "Live sites:"

  echo "  live:" >> ${_SUBS_INFO_REPORT_FILE}

  for _SUB_SITE in ${_SUB_SITES}; do

    local _SUB_SITE_IS_LIVE=true

    if [[ ! "${_SUB_SITE}" == "all" ]] && [[ ! "${_SUB_SITE}" == "brandsite" ]] && [[ ! "${_SUB_SITE}" == "default" ]]; then

      local _SUB_SITE_BASE_NAME=$(site_configuration_get_base_name_from_folder ${_SUB_SITE} ${_SUBS_INFO_SUBSCRIPTION})

      if [ ! -z "${_SUB_SITE_BASE_NAME}" ]; then

        local _SUB_SITE_PROD_URLS=$(site_configuration_get_domains "${_SUBS_INFO_SUBSCRIPTION}" "prod" "${_SUB_SITE_BASE_NAME}")

        if [ -n "${_SUB_SITE_PROD_URLS}" ]; then

          for _SUB_SITE_PROD_URL in ${_SUB_SITE_PROD_URLS}; do

            if (! in_list? ${_SUB_SITE_PROD_URL} "${_SUBSCRIPTION_PROD_URLS}"); then

              _SUB_SITE_IS_LIVE=false
              break

            fi

          done

        else

          _SUB_SITE_IS_LIVE=false

        fi

        if (${_SUB_SITE_IS_LIVE}); then

          out_success "  - ${_SUB_SITE}"
          echo "    - ${_SUB_SITE_BASE_NAME}" >> ${_SUBS_INFO_REPORT_FILE}

          # Set global subsite sample for current subscription
          _SUBS_INFO_SAMPLE_SITE="${_SUB_SITE}"

        fi

      fi

    fi

  done

}

function subs_info_get_subscription_region() {

  local _SUBS_INFO_SUBSCRIPTION=${1:-}
  local _SUBS_INFO_ENV="prod"

  local _SUBS_INFO_SUBS_REGION=$(subscription_configuration_get_region ${_SUBS_INFO_SUBSCRIPTION})
  echo "  region: ${_SUBS_INFO_SUBS_REGION}" >> ${_SUBS_INFO_REPORT_FILE}

}

function subs_info_get_subscription_name() {

  local _SUBS_INFO_SUBSCRIPTION=${1:-}
  local _SUBS_INFO_ENV="prod"

  # local _SUBS_INFO_SUBS_NAME=$(drush_vget acquia_subscription_name "@${_SUBS_INFO_SUBSCRIPTION}.${_SUBS_INFO_ENV} -l ${_SUBS_INFO_SAMPLE_SITE} vget acquia_subscription_name")
  local _SUBS_INFO_SUBS_NAME=$(acquia_get_info_from_ac ${_SUBS_INFO_SUBSCRIPTION} ${_SUBS_INFO_ENV} ac-site-info title)
  out_info "Subscription name found: ${_SUBS_INFO_SUBS_NAME}"

  echo "  subscription_name: ${_SUBS_INFO_SUBS_NAME}" >> ${_SUBS_INFO_REPORT_FILE}

}

function subs_info_get_sites() {

  local _SUBS_INFO_SUBSCRIPTION=${1:-}
  local _ENV=${2:-}

  local _SUB_SITES=$(drush_get_subsites_from_acquia ${_SUBS_INFO_SUBSCRIPTION} ${_ENV})

  out_info "Sites found:"

  echo "    sites:" >> ${_SUBS_INFO_REPORT_FILE}

  for _SUB_SITE in ${_SUB_SITES}; do

    if [[ ! "${_SUB_SITE}" == "all" ]] && [[ ! "${_SUB_SITE}" == "brandsite" ]] && [[ ! "${_SUB_SITE}" == "default" ]]; then

      local _SUB_SITE_BASE_NAME=$(site_configuration_get_base_name_from_folder ${_SUB_SITE} ${_SUBS_INFO_SUBSCRIPTION})

      out_success "  - ${_SUB_SITE}"

      if [ -z "${_SUB_SITE_BASE_NAME}" ]; then

        # Site not configured in config files
        _SUB_SITE_BASE_NAME="unknown"

      fi

      echo "      - ${_SUB_SITE_BASE_NAME}" >> ${_SUBS_INFO_REPORT_FILE}

    fi

  done

}

function subs_info_get_platform_version() {

  local _SUBS_INFO_SUBSCRIPTION=${1:-}
  local _SUBS_INFO_ENV=${2:-}

  local _PLATFORM_VERSION=""

  if [ -n "${_SUBS_INFO_SAMPLE_SITE}" ]; then

    _PLATFORM_VERSION=$(drush_subsite_eval_from_acquia ${_SUBS_INFO_SUBSCRIPTION} ${_SUBS_INFO_ENV} ${_SUBS_INFO_SAMPLE_SITE} "print(JJBOS_VERSION);")

  fi

  if [ -n "${_PLATFORM_VERSION}" ]; then

    out_info "Platform version found: ${_PLATFORM_VERSION}"

  else

    out_danger "No platform version found"

  fi


  echo "    platform_version: ${_PLATFORM_VERSION}" >> ${_SUBS_INFO_REPORT_FILE}

}

function subs_info_get_drupal_version() {

  local _SUBS_INFO_SUBSCRIPTION=${1:-}
  local _SUBS_INFO_ENV=${2:-}

  local _DRUPAL_VERSION=""

  if [ -n "${_SUBS_INFO_SAMPLE_SITE}" ]; then

    _DRUPAL_VERSION=$(drush_command_on_subsite_from_acquia ${_SUBS_INFO_SUBSCRIPTION} ${_SUBS_INFO_ENV} ${_SUBS_INFO_SAMPLE_SITE} "st drupal-version --format=list")

  fi

  if [ -n "${_DRUPAL_VERSION}" ]; then

    out_info "Drupal core version found: ${_DRUPAL_VERSION}"

  else

    out_danger "No Drupal core version found"

  fi


  echo "    drupal_version: ${_DRUPAL_VERSION}" >> ${_SUBS_INFO_REPORT_FILE}

}
