#!/usr/bin/env bash

function prelaunch_check_get_plat_branch_from_version() {

  if [ -z ${1:-} ]; then

    raise RequiredParameterNotFound "[prelaunch_check_get_plat_branch_from_version] Please provide a valid OS platform version"

  else

    local _PRELAUNCH_CHECK_PLAT_VERSION=${1}

  fi

  echo ${_PRELAUNCH_CHECK_SRC_PLAT_BRANCHES} | sed "s/ /\n/g" | grep ${_PRELAUNCH_CHECK_PLAT_VERSION}

}

function prelaunch_check_analyze_diffs() {

  local _PRELAUNCH_CHECK_JJBOS_PROFILE_PATH="docroot/profiles/jjbos"
  local _PRELAUNCH_CHECK_DIFFS=$(rsync -rcn --include "core" --out-format="%n" ${_OS_UTILS_PLATFORM_WORKSPACE}/${_PRELAUNCH_CHECK_JJBOS_PROFILE_PATH}/ ${_PRELAUNCH_CHECK_REPO_PATH}/${_PRELAUNCH_CHECK_JJBOS_PROFILE_PATH}/ | sort -u)

  out_info "Platform core diff:" 1
  local _PRELAUNCH_CHECK_DIFF_OUTPUT=$(echo "${_PRELAUNCH_CHECK_DIFFS}" | grep -Ev "^modules/" | grep -Ev "^themes/" | grep -Ev "^libraries/")
  [ -n "${_PRELAUNCH_CHECK_DIFF_OUTPUT}" ] && echo -e ${BRED}${_PRELAUNCH_CHECK_DIFF_OUTPUT}${COLOR_OFF}
  [ -z "${_PRELAUNCH_CHECK_DIFF_OUTPUT}" ] && out_success "No core customizations found"

  out_info "Platform libraries diff:" 1
  local _PRELAUNCH_CHECK_DIFF_OUTPUT=$(echo "${_PRELAUNCH_CHECK_DIFFS}" | grep -E "^libraries/" | sed -E "s#libraries/([^/]+)/.*#\1#g" | sort -u)
  [ -n "${_PRELAUNCH_CHECK_DIFF_OUTPUT}" ] && echo -e ${BRED}${_PRELAUNCH_CHECK_DIFF_OUTPUT}${COLOR_OFF}
  [ -z "${_PRELAUNCH_CHECK_DIFF_OUTPUT}" ] && out_success "No libraries customizations were found"

  out_info "Platform modules diff:" 1
  local _PRELAUNCH_CHECK_DIFF_OUTPUT=$(echo "${_PRELAUNCH_CHECK_DIFFS}" | grep -E "^modules/" | sed -E "s#modules/([^/]+/[^/]+)/.*#\1#g" | sort -u)
  [ -n "${_PRELAUNCH_CHECK_DIFF_OUTPUT}" ] && echo -e ${BRED}${_PRELAUNCH_CHECK_DIFF_OUTPUT}${COLOR_OFF}
  [ -z "${_PRELAUNCH_CHECK_DIFF_OUTPUT}" ] && out_success "No modules customizations were found"

  out_info "Platform themes diff:" 1
  local _PRELAUNCH_CHECK_DIFF_OUTPUT=$(echo "${_PRELAUNCH_CHECK_DIFFS}" | grep -E "^themes/" | sed -E "s#themes/([^/]+)/.*#\1#g" | sort -u)
  [ -n "${_PRELAUNCH_CHECK_DIFF_OUTPUT}" ] && echo -e ${BRED}${_PRELAUNCH_CHECK_DIFF_OUTPUT}${COLOR_OFF}
  [ -z "${_PRELAUNCH_CHECK_DIFF_OUTPUT}" ] && out_success "No theme customizations were found"

  out_info "Manual check: meld ${_OS_UTILS_PLATFORM_WORKSPACE}/${_PRELAUNCH_CHECK_JJBOS_PROFILE_PATH}/ ${_PRELAUNCH_CHECK_REPO_PATH}/${_PRELAUNCH_CHECK_JJBOS_PROFILE_PATH}/" 1

}

function prelaunch_check_analyze_logs() {

  local _PRELAUNCH_CHECK_ANALYZE_SUBSCRIPTION=${1:-}
  local _PRELAUNCH_CHECK_ANALYZE_DEFAULT_ENVIRONMENT=${2:-}
  local _PRELAUNCH_CHECK_ANALYZE_SITE=${3:-}
  local _PRELAUNCH_CHECK_ANALYZE_LOGS_PATH=${4:-}
  shift 4

  local _PRELAUNCH_CHECK_ANALYZE_ERROR_LOGS=${@}

  if [ -z "${_PRELAUNCH_CHECK_ANALYZE_SUBSCRIPTION}" ]; then

    raise RequiredParameterNotFound "[prelaunch_check_analyze_logs] Please provide a subscription"

  fi

  if [ -z "${_PRELAUNCH_CHECK_ANALYZE_DEFAULT_ENVIRONMENT}" ]; then

    raise RequiredParameterNotFound "[prelaunch_check_analyze_logs] Please provide a environment"

  fi


  if [ -z "${_PRELAUNCH_CHECK_ANALYZE_SITE}" ]; then

    raise RequiredParameterNotFound "[prelaunch_check_analyze_logs] Please provide a site"

  fi

  if [ -z "${_PRELAUNCH_CHECK_ANALYZE_LOGS_PATH}" ] && [ ! -d ${_PRELAUNCH_CHECK_ANALYZE_LOGS_PATH} ]; then

    raise RequiredParameterNotFound "[prelaunch_check_analyze_logs] Please provide a log path"

  fi

  out_warning "Analyzing logs ${_PRELAUNCH_CHECK_ANALYZE_ERROR_LOGS}" 1
  local _PRELAUNCH_CHECK_LOGS_ANALYZE_PATH="${_PRELAUNCH_CHECK_ANALYZE_LOGS_PATH}/${_PRELAUNCH_CHECK_ANALYZE_SUBSCRIPTION}.${_PRELAUNCH_CHECK_ANALYZE_DEFAULT_ENVIRONMENT}"

  for _LOG_FILE in ${_PRELAUNCH_CHECK_ANALYZE_ERROR_LOGS}; do

    local _LOG_FILE_PATH="${_PRELAUNCH_CHECK_LOGS_ANALYZE_PATH}/${_LOG_FILE}"
    parse_log ${_LOG_FILE_PATH} ${_PRELAUNCH_CHECK_ANALYZE_SITE}

  done

}
