#!/usr/bin/env bash

function domain_report_load_configurations() {

  if [ -z ${1:-} ]; then

    raise RequiredParameterNotFound "[domain_report_load_configurations] Please provide a valid subscription"

  else

    _DOMAIN_REPORT_SUBSCRIPTION=${1}

  fi

  if [ -z ${2:-} ]; then

    raise RequiredParameterNotFound "[domain_report_load_configurations] Please provide a valid environment"

  else

    _DOMAIN_REPORT_ENV=${2}

  fi

}

function domain_report_init() {

  metrics_add ${_DOMAIN_REPORT_SUBSCRIPTION}
  metrics_add ${_DOMAIN_REPORT_ENV}

}

function domain_report_get_domains() {

  out_warning "Getting acquia domains" 1

  # Removing acquia default domain using grep
  _DOMAIN_REPORT_LIST=$(acquia_domain_list ${_DOMAIN_REPORT_SUBSCRIPTION} ${_DOMAIN_REPORT_ENV} \
        | ${_GREP} -ve ${_DOMAIN_REPORT_SUBSCRIPTION} | ${_SED} 's/^/ /g')
  out_check_status $? "Domains retrieved successfully" "Error while retrieving domains"

}

function domain_report_get_address() {

  out_warning "Getting ip address" 1

  _DOMAIN_REPORT=""
  _DOMAIN_REPORT_VIEW=""

  for _DOMAIN in ${_DOMAIN_REPORT_LIST}; do

    local _DOMAIN_IP=$(get_ip_by_domain ${_DOMAIN})
    _DOMAIN_REPORT="${_DOMAIN_REPORT}\n${_DOMAIN_IP} - ${_DOMAIN}"
    _DOMAIN_REPORT_VIEW="${_DOMAIN_REPORT_VIEW}\n\t${_DOMAIN_IP} - ${_DOMAIN}"

  done

  [[ -n ${_DOMAIN_REPORT} ]] && true
  out_check_status $? "Ip address got with success" "Error while getting ip address"

}

function domain_report_list() {

  out_warning "Generating report" 1
  echo -e "${BIPURPLE}$(echo -e ${_DOMAIN_REPORT_VIEW}  | ${_SORT}) ${COLOR_OFF}"

}

function domain_report_file() {

  local _DOMAIN_REPORT_PATH="/tmp/${_TASK_NAME}"
  local _DOMAIN_REPORT_FILE="${_DOMAIN_REPORT_PATH}/${_DOMAIN_REPORT_SUBSCRIPTION}_${_DOMAIN_REPORT_ENV}.csv"

  out_warning "Generating report file in: ${_DOMAIN_REPORT_FILE}" 1

  filesystem_create_folder_777 ${_DOMAIN_REPORT_PATH}

  echo "Ip address - Domains"  | ${_SORT} | ${_SED} 's/ - /,/g' > ${_DOMAIN_REPORT_FILE}
  echo -e ${_DOMAIN_REPORT}  | ${_SORT} | ${_SED} 's/ - /,/g' >> ${_DOMAIN_REPORT_FILE}
  out_check_status $? "File gererated in ${_DOMAIN_REPORT_FILE}" "Erro while generating report file"

}
