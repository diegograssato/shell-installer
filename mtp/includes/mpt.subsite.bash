#!/usr/bin/env bash

function mtp_get_affected_themes() {

  local _MTP_AFFECTED_FILES="";
  # Get affected files
  for _COMMIT in ${_MTP_GIT_COMMITS}; do

    local _COMMIT_FILES="$(${_MTP_RUN_GIT_ACQUIA} show --pretty="format:" --name-only ${_COMMIT})"
    _MTP_AFFECTED_FILES="${_MTP_AFFECTED_FILES} ${_COMMIT_FILES}"

  done

  # Detect modifications in plataform level(scss|css|js)
  local _MTP_DETECT_THEME_MODIFICATION=$(echo ${_MTP_AFFECTED_FILES} | sed 's/ /\n/g' | grep -E ".*\.(scss)" | grep -Eo "docroot\/profiles\/jjbos\/themes\/[^\/]+" | sort | uniq | wc -l)

  if [ ${_MTP_DETECT_THEME_MODIFICATION} -ge 1 ]; then

    _MTP_PLATFORM_CODE_MODIFICATION=true

    local _MTP_SITES=$(subscription_configuration_get_sites ${_MTP_SUBSCRIPTION})
    local _MTP_AFFECTED_SUBSITES=""

    for _SITE in ${_MTP_SITES}; do

      local _MTP_DOMAIN_LIST=$(site_configuration_get_domains ${_MTP_SUBSCRIPTION} ${_MTP_ENVIRONMENT_TEST} ${_SITE})
      local _DOMAIN=$(echo "${_MTP_DOMAIN_LIST}" | ${_SED} -e "s/\s/\n/g" | ${_GREP} "^con\|^www" | head -1)
      if [[ ${_MTP_SUBSCRIPTION} == "osops" ]]; then

        local _DOMAIN=$(echo "${_MTP_DOMAIN_LIST}" | ${_SED} -e "s/\s/\n/g" | head -1)

      fi

      local _MTP_AFFECTED_SUBSITES_FROM_ACQUIA="$(${_MTP_DRUSH_FROM_ACQUIA} -l ${_DOMAIN} vget theme_default --format=json)";
      local _MTP_AFFECTED_SUBSITES_FROM_ACQUIA=$(echo ${_MTP_AFFECTED_SUBSITES_FROM_ACQUIA} | ${_SED} -e 's|"||g')

      local _SUB_SITE=$(site_configuration_get_subsite_name ${_SITE} ${_MTP_SUBSCRIPTION})
      local _MTP_CHECK_THEME_PATH="${_MTP_ACQUIA_SUBSCRIPTION_PATH}/docroot/sites/${_SUB_SITE}/themes/${_MTP_AFFECTED_SUBSITES_FROM_ACQUIA}"
      if [ -d ${_MTP_CHECK_THEME_PATH} ]; then

        local _MTP_AFFECTED_SUBSITES_FROM_ACQUIA="docroot/sites/${_SUB_SITE}/themes/${_MTP_AFFECTED_SUBSITES_FROM_ACQUIA}"
        local _MTP_AFFECTED_SUBSITES="${_MTP_AFFECTED_SUBSITES_FROM_ACQUIA} ${_MTP_AFFECTED_SUBSITES}"

      fi

    done

    echo ${_MTP_AFFECTED_SUBSITES}

  else

    # Filter and return affected themes
    echo ${_MTP_AFFECTED_FILES} | sed 's/ /\n/g' | grep -Ev ".*\.(php|info)" | grep -Eo "(docroot\/sites\/[^\/]+\/|src\/)themes\/[^\/]+" | grep -Ev "(docroot\/sites\/[^\/]+\/|src\/)themes\/(brand_group|brand_theme|brand_theme_blank)" | sort | uniq

  fi

}

function mtp_get_affected_subsites() {

  local _MTP_AFFECTED_SUBSITES="";
  # Get affected files
  for _COMMIT in ${_MTP_GIT_COMMITS}; do

    local _COMMIT_FILES="$(${_MTP_RUN_GIT_ACQUIA} show --pretty="format:" --name-only ${_COMMIT})"
    local _COMMIT_FILES_FORMATED="$(echo  ${_COMMIT_FILES}| grep -Eo '(docroot\/sites\/[^\/]+)'  | sed 's|docroot\/sites\/||g'  | sort | uniq)"
    _MTP_AFFECTED_SUBSITES="${_MTP_AFFECTED_SUBSITES} ${_COMMIT_FILES_FORMATED}"

  done

  echo ${_MTP_AFFECTED_SUBSITES}  | sed 's/ /\n/g'| sort | uniq

}

# Only Subscription OSOPS for development
function mtp_switch_env_dev() {

  if [[ "${_MTP_SUBSCRIPTION}" == "osops" ]]; then

    out_info "Switching Acquia Environments for Testing Subscription" 1

    _MTP_ENVIRONMENT_PROD="test"
    _MTP_ENVIRONMENT_TEST="dev"

  fi

}

function mtp_get_sites() {

  local _MTP_SITES_FOLDER=$(mtp_get_affected_subsites)
  local _MTP_SITES=""
  for _MTP_SITE_FOLDER in ${_MTP_SITES_FOLDER}; do

    local _MTP_SITES_TMP=$(site_configuration_get_base_name_from_folder ${_MTP_SUBSCRIPTION} ${_MTP_SITE_FOLDER})
    _MTP_SITES="${_MTP_SITES_TMP} ${_MTP_SITES}"

  done

  echo ${_MTP_SITES}

}

####### FUTURE CHANGES IN PLATAFORM LEVEL - IN PLANING #############
function mtp_get_affected_subscription_all_subsites() {

  local _MTP_AFFECTED_SUBSITES="";
  local _MTP_DOCROOT_SITE="${_MTP_ACQUIA_SUBSCRIPTION_PATH}/docroot/sites/"
  local _MTP_AFFECTED_DATABASES=""

  for i in $(ls -d ${_MTP_DOCROOT_SITE}*/ |grep -Ev "all|brandsite|default"); do

    local _COMMIT_FILES_FORMATED=$(echo ${i%%/} | sed "s|${_MTP_DOCROOT_SITE}||g"  | sort | uniq)
    local _MTP_AFFECTED_SUBSITES="${_MTP_AFFECTED_SUBSITES} ${_COMMIT_FILES_FORMATED}"

  done

  echo ${_MTP_AFFECTED_SUBSITES}  | sed 's/ /\n/g'| sort | uniq

}

function mtp_get_affected_subscription_all_themes() {

  local _MTP_AFFECTED_SUBSITES="$(drush @osops.test -l osopsf79eqmmybr.devcloud.acquia-sites.com  vget theme_default --format=json)";
  echo ${_MTP_AFFECTED_SUBSITES} | sed 's/ /\n/g'|sed -e 's|"||g' | head -1

}
