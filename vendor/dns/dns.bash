#!/usr/bin/env bash
function dns_prepare() {

    if [ -z ${_DNS_SERVER_KEY:-} ]; then

      raise RequiredConfigNotFound "Please configure variable _DNS_SERVER_KEY for integrating whith DNS Server"

    fi

    if [ -z ${_DNS_SERVER_IP:-} ]; then

      raise RequiredConfigNotFound "Please configure variable _DNS_SERVER_IP for integrating whith DNS Server"

    fi

    if [ -z ${_DNS_TTL:-} ]; then

      raise RequiredConfigNotFound "Please configure variable _DNS_TTL for integrating whith DNS Server"

    fi

}

function dns_add_url() {

  local _DNS_URL="${1:-}"
  local _SERVER_IP=${2:-}
  local _REGEX_URL='(https?|ftp|file)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]'
  local _IP_CHECK=$(echo ${_SERVER_IP:0:15} | sed "s/[0-9]\{1,3\}//g")
  dns_prepare

  if [ -z ${_DNS_URL}  ]; then

    raise RequiredParameterNotFound "[dns_add_url] Please provide a valid URL"

  fi

  if [ -z ${_SERVER_IP}  ]; then

    raise RequiredParameterNotFound "[dns_add_url] Please provide a valid IP"

  fi

  if [ ${_DNS_URL} == ${_REGEX_URL} ]; then

    raise RequiredParameterNotFound "[dns_add_url] Please provide a valid URL"

  fi

  if [ ${_IP_CHECK} == ${_SERVER_IP} ]; then

    raise RequiredParameterNotFound "[dns_add_url] Please provide a valid IP"

  fi

#dig @172.16.38.219 www-us-mcneil-qa.citdev. A
#dig @172.16.38.219 www-us-mcneil-qa.citdev. TXT

  nsupdate -y "${_DNS_SERVER_KEY}" -v << EOF
server ${_DNS_SERVER_IP}
update add ${_DNS_URL}. ${_DNS_TTL} A  ${_SERVER_IP}
update add ${_DNS_URL}. ${_DNS_TTL} TXT "Updated on $(date)"
send
EOF
  out_check_status $? "Host ${_DNS_URL} changed with success" "Update host ${_DNS_URL} failed"

}

function dns_delete_url() {

  local _DNS_URL=${1:-}
  local _REGEX_URL='(https?|ftp|file)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]'
  dns_prepare
  
  if [ -z ${_DNS_URL}  ]; then

    raise RequiredParameterNotFound "[dns_add_url] Please provide a valid URL"

  fi

  if [ ${_DNS_URL} == ${_REGEX_URL} ]; then

    raise RequiredParameterNotFound "[dns_delete_url] Please provide a valid URL"

  fi

  nsupdate -y "${_DNS_SERVER_KEY}" -v << EOF
server ${_DNS_SERVER_IP}
update delete ${_DNS_URL}. A
update delete ${_DNS_URL}. TXT
send
EOF
  out_check_status $? "Host ${_DNS_URL} deleted with success" "Failed to remove host ${_DNS_URL}"

}
