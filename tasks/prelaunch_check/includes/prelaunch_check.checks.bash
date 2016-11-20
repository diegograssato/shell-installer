#!/usr/bin/env bash

function prelaunch_check_page() {

  if [ -z ${1:-} ]; then

    raise RequiredParameterNotFound "[prelaunch_check_page] Please provide a valid page"

  else

    local _PRELAUNCH_CHECK_PAGE=${1}

  fi

  local _SUCCESS=""

  out_info "Checking ${_PRELAUNCH_CHECK_PAGE} page" 1
  local _PRELAUNCH_CHECK_SITEMAP_XML=$(curl -L -s -o /dev/null -w "%{http_code}" --insecure --user ${_PRELAUNCH_CHECK_BASIC_AUTH} ${_PRELAUNCH_CHECK_SITE_URL}/${_PRELAUNCH_CHECK_PAGE})

  [ ${_PRELAUNCH_CHECK_SITEMAP_XML} -eq 200 ] && true
  out_check_status $? "OK: ${_PRELAUNCH_CHECK_PAGE}" "NOK: ${_PRELAUNCH_CHECK_PAGE}"

}
