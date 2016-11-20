#!/usr/bin/env bash

function mts_list_commits() {

  for _COMMIT in ${_MTS_GIT_COMMITS}; do

    local _MTS_GIT_COMMITS_FILTER='log --pretty=tformat:%x1b[32m%H%x1b[0m%x20%s%x20%x1b[33m(%an)%x1b[0m -n 1'
    local _MTS_MSG=$(${_MTS_RUN_GIT_SUBSITE} ${_MTS_GIT_COMMITS_FILTER} ${_COMMIT})
    echo -e "\t${_MTS_MSG}"

  done

}

function mts_get_affected_themes() {

  local _MTS_AFFECTED_FILES="";

  # Get affected files
  for _COMMIT in ${_MTS_GIT_COMMITS}; do

    local _COMMIT_FILES="$(${_MTS_RUN_GIT_SUBSITE} show --pretty="format:" --name-only ${_COMMIT})"
    _MTS_AFFECTED_FILES="${_MTS_AFFECTED_FILES} ${_COMMIT_FILES}"

  done

  # Filter and return affected themes
  echo ${_MTS_AFFECTED_FILES} | sed 's/ /\n/g' | grep -Ev ".*\.(php|info)" | grep -Eo "(docroot\/sites\/[^\/]+\/|src\/)themes\/[^\/]+" | grep -Ev "src\/themes\/(brand_group|brand_theme|brand_theme_blank)" | sort | uniq || true

}

function mts_validate_duplicate_deployment() {

  for _TICKET in ${_MTS_TICKET_ID}; do

    local _MTS_GIT_FILTER_RESULT=$(${_MTS_RUN_GIT_ACQUIA} log | ${_GREP} -c "${_TICKET}")

    if [ ${_MTS_GIT_FILTER_RESULT} -gt 0 ]; then

      mts_abort "TicketInStage" "This ticket is already in stage, please, try another jira ticket or the interactive mode."

    fi

  done

}
