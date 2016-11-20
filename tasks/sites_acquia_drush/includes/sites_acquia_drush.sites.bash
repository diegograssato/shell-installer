#!/usr/bin/env bash

function sites_acquia_drush_load_acquia_sites() {

  out_info "Loading subsites from Acquia [ ${_SITES_ACQUIA_DRUSH_SUBSCRIPTION}.${_SITES_ACQUIA_DRUSH_ENVIRONMENT} ]"
  local _SITES_ACQUIA_DRUSH_ACQUIA_SITES=$(drush_get_subsites_from_acquia ${_SITES_ACQUIA_DRUSH_SUBSCRIPTION} ${_SITES_ACQUIA_DRUSH_ENVIRONMENT})
  out_check_status $? "Sites found:" "Error while retrieving sites"

  for _SUB_SITE in ${_SITES_ACQUIA_DRUSH_ACQUIA_SITES}; do

    if [[ ! "${_SUB_SITE}" == "all" ]] && [[ ! "${_SUB_SITE}" == "brandsite" ]] && [[ ! "${_SUB_SITE}" == "default" ]]; then

      echo "${_SUB_SITE}" | tee -a ${_SITES_ACQUIA_DRUSH_ACQUIA_FILE}

    fi

  done

}

function sites_acquia_drush_load_yml_sites() {

  out_info "Checking subsites from YML for [ ${_SITES_ACQUIA_DRUSH_SUBSCRIPTION} ]" 1
  local _SITES_ACQUIA_DRUSH_YML_SITES=$(subscription_configuration_get_sites ${_SITES_ACQUIA_DRUSH_SUBSCRIPTION})
  out_check_status $? "Sites found:" "Error while retrieving sites"

  for _SUB_SITE in ${_SITES_ACQUIA_DRUSH_YML_SITES}; do

    local _SUB_SITE_FOLDER_NAME=$(site_configuration_get_subsite_name ${_SUB_SITE} ${_SITES_ACQUIA_DRUSH_SUBSCRIPTION})

    if [[ -n "${_SUB_SITE_FOLDER_NAME}" ]]; then

      echo "${_SUB_SITE_FOLDER_NAME}" | tee -a ${_SITES_ACQUIA_DRUSH_YML_FILE}

    else

      out_danger "Site [ ${_SUB_SITE} ] not found in configuration file [ ${_SITES_ACQUIA_DRUSH_YML_SUBSCRIPTION_FILE_SUBSITE} ]"
      out_notify "Site not found in config" "Site [ ${_SUB_SITE} ] not found in configuration file [ ${_SITES_ACQUIA_DRUSH_YML_SUBSCRIPTION_FILE_SUBSITE} ]" ${_NOTIFY_ANGRY}
      out_warning "You should add it in [ ${_SITES_ACQUIA_DRUSH_YML_SUBSCRIPTION_FILE_SUBSITE} ] or remove it from [ ${_SITES_ACQUIA_DRUSH_YML_SUBSCRIPTION_FILE_CONFIGURATION} ]"
      out_confirm "Site will be ignored anyway. Enter anything to proceed. .* = y" 1 && true

      continue

    fi

  done

}
