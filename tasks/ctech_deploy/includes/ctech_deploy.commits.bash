#!/usr/bin/env bash

function ctech_deploy_list_commits() {

  for _COMMIT in ${_CTECH_DEPLOY_GIT_COMMITS}; do

    local _CTECH_DEPLOY_GIT_COMMITS_FILTER='log --pretty=tformat:%x1b[32m%H%x1b[0m%x20%s%x20%x1b[33m(%an)%x1b[0m -n 1'
    local _CTECH_DEPLOY_MSG=$(${_CTECH_DEPLOY_RUN_GIT_SUBSITE} ${_CTECH_DEPLOY_GIT_COMMITS_FILTER} ${_COMMIT})
    echo -e "\t${_CTECH_DEPLOY_MSG}"

  done

}

function ctech_deploy_get_affected_themes() {

  local _CTECH_DEPLOY_AFFECTED_FILES="";

  # Get affected files
  for _COMMIT in ${_CTECH_DEPLOY_GIT_COMMITS}; do

    local _COMMIT_FILES="$(${_CTECH_DEPLOY_RUN_GIT_SUBSITE} show --pretty="format:" --name-only ${_COMMIT})"
    _CTECH_DEPLOY_AFFECTED_FILES="${_CTECH_DEPLOY_AFFECTED_FILES} ${_COMMIT_FILES}"

  done

  # Filter and return affected themes
  echo ${_CTECH_DEPLOY_AFFECTED_FILES} | sed 's/ /\n/g' | grep -Ev ".*\.(php|info)" | grep -Eo "(docroot\/sites\/[^\/]+\/|src\/)themes\/[^\/]+" | grep -Ev "src\/themes\/(brand_group|brand_theme|brand_theme_blank)" || true

}
