#!/usr/bin/env bash

function build_qa_site_load_repositories() {

  out_warning "Loading Subsite and Subscription repositories" 1

  git_load_repositories ${_BUILD_QA_SITE_SUBSITE_REPO} ${_BUILD_QA_SITE_SUBSITE_BRANCH} ${_BUILD_QA_SITE_SUBSITE_PATH}
  git_load_repositories ${_BUILD_QA_SITE_PLATFORM_PLATFORM_REPO} ${_BUILD_QA_SITE_PLATFORM_ACQUIA_BRANCH} ${_BUILD_QA_SITE_SUBSCRIPTION_PATH}

}
