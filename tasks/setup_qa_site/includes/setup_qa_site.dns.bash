#!/usr/bin/env bash

function setup_qa_site_dns_urls() {

  local _SETUP_QA_SITE_QA_DOMAINS=$(site_configuration_get_subsite_qa_domains ${_SETUP_QA_SITE_SUBSITE} ${_SETUP_QA_SITE_SUBSCRIPTION})

  echo ${_SETUP_QA_SITE_QA_DOMAINS}

}

function setup_qa_site_dns_add() {

  local _SETUP_QA_SITE_DNS_URL=${1:-}
  dns_delete_url ${_SETUP_QA_SITE_DNS_URL}
  dns_add_url ${_SETUP_QA_SITE_DNS_URL} ${_SETUP_QA_SITE_SERVER_IP}

}
