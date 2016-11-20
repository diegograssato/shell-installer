#!/usr/bin/env bash

function mtp_validate_is_deployed() {


  for _TICKET in ${_MTP_TICKETS}; do

    local _MTP_GIT_FILTER_RESULT=$(${_MTP_RUN_GIT_ACQUIA} log ${_MTP_ACQUIA_REPO_PROD_RESOURCE} | ${_GREP} -c "${_TICKET}")
    if [ ${_MTP_GIT_FILTER_RESULT} -gt 0 ]; then

      mtp_abort "TicketInProduction" "This ticket ${_TICKET} is already in production, pĺease, try another jira ticket or the interactive mode."

    fi

  done

}

function mtp_list_commits() {

  for _COMMIT in ${_MTP_GIT_COMMITS}; do

    local _MTP_GIT_COMMITS_FILTER="log --pretty=tformat:%x1b[32m%H%x1b[0m%x20%s%x20%x1b[33m(%an)%x1b[0m -n 1"

    local _MTP_MSG=$(${_MTP_RUN_GIT_ACQUIA} ${_MTP_GIT_COMMITS_FILTER} ${_COMMIT})
    echo -e "\t${_MTP_MSG}"

  done

}

function mtp_cherry_pick() {

  local _MTP_GIT_COMMITS_TMP=""
  local _MTP_DETECT_CODE_MODIFICATION_SIZE=0
  local _MTP_DETECT_CODE_MODIFICATION_HTACCESS_SIZE=0

  for _COMMIT in ${_MTP_GIT_COMMITS}; do

    if [ ${_MTP_INTERACTIVE} == true ]; then

      local _COMMIT_VIEW=$(${_MTP_RUN_GIT_ACQUIA} show --no-patch --oneline  --pretty=tformat:"%x1b[32m%h%x1b[0m%x20%s%x20%x1b[33m(%an - %cD)%x1b[0m" ${_COMMIT})
      out_confirm "Do you want to apply the commit: \n${_COMMIT_VIEW}" 1 && true
      if [ $? -ge 1 ]; then

        continue;

      fi
      local _MTP_GIT_COMMITS_TMP="${_COMMIT} ${_MTP_GIT_COMMITS_TMP}"

    else

      local _MTP_GIT_COMMITS_TMP="${_COMMIT} ${_MTP_GIT_COMMITS_TMP}"

    fi

    git_cherry_pick ${_MTP_ACQUIA_SUBSCRIPTION_PATH} ${_COMMIT} && true
    if [ $? -ge 1 ]; then

      if [ ${_MTP_INTERACTIVE} == true ]; then

        out_warning "Problems encountered while applying the commit: \n${_COMMIT_VIEW}"
        out_confirm "Please resolve manually and continue?" 1 && true
        if [ $? -ge 1 ]; then

          out_danger "Applying the commit  not solved. Aborting."

        else

          out_danger "Problems encountered while applying the commit ${_COMMIT} was aborted. Please check manually."

        fi

      else

         mtp_abort "CherryPickError" "Problems encountered while applying the commit ${_COMMIT}. Please resolve manually and continue."

      fi

    fi

    # Detect modifications in platform level ignore theme
    local _MTP_COMMIT_FILES="$(${_MTP_RUN_GIT_ACQUIA} show --pretty="format:" --name-only ${_COMMIT})"
    local _MTP_DETECT_CODE_MODIFICATION=$(echo ${_MTP_COMMIT_FILES} | sed 's/ /\n/g' | grep -Ev ".*\.(css|scss)" | grep -Eo "(docroot\/profiles\/jjbos)\/[^\/]+" | sort | uniq | wc -l)

    local _MTP_DETECT_CODE_MODIFICATION_SIZE=$(expr ${_MTP_DETECT_CODE_MODIFICATION} + ${_MTP_DETECT_CODE_MODIFICATION_SIZE})

    # Detect modifications in plataform level (htaccess changes)
    local _MTP_DETECT_CODE_MODIFICATION_HTACCESS_CHECK=$(echo ${_MTP_COMMIT_FILES} | sed 's/ /\n/g' | grep -Eo "docroot\/.htaccess" | sort | uniq | wc -l)
    local _MTP_DETECT_CODE_MODIFICATION_HTACCESS_SIZE=$(expr ${_MTP_DETECT_CODE_MODIFICATION_HTACCESS_CHECK} + ${_MTP_DETECT_CODE_MODIFICATION_HTACCESS_SIZE})

  done

  if [ ${_MTP_DETECT_CODE_MODIFICATION_SIZE} -ge 1 ]; then

    _MTP_PLATFORM_CODE_MODIFICATION=true

  fi

  if [ ${_MTP_DETECT_CODE_MODIFICATION_HTACCESS_SIZE} -ge 1 ]; then

    _MTP_DETECT_CODE_MODIFICATION_HTACCESS=true

  fi

  # Update variable with only selected commits
  _MTP_GIT_COMMITS=${_MTP_GIT_COMMITS_TMP}

}
