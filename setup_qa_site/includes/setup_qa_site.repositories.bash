#!/usr/bin/env bash

function setup_qa_site_load_repositories() {

  out_warning "Loading Subsite and Subscription repositories" 1

  if [ -d ${_SETUP_QA_SITE_SUBSITE_PATH} ]; then

    out_warning "Cleaning folder ${_SETUP_QA_SITE_SUBSITE_PATH}"
    ${_RMF} ${_SETUP_QA_SITE_SUBSITE_PATH}

  fi

  git_load_repositories ${_SETUP_QA_SITE_SUBSITE_REPO} ${_SETUP_QA_SITE_SUBSITE_BRANCH} ${_SETUP_QA_SITE_SUBSITE_PATH}
  git_load_repositories ${_SETUP_QA_SITE_PLATFORM_PLATFORM_REPO} ${_SETUP_QA_SITE_PLATFORM_ACQUIA_BRANCH} ${_SETUP_QA_SITE_SUBSCRIPTION_PATH}

}
