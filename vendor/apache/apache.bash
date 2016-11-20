#!/usr/bin/env bash

import drush


function apache_prepare() {

    if [ -z ${_APACHE_SITES_AVAILABLE:-} ]; then

      raise RequiredConfigNotFound "Please configure variable _APACHE_SITES_AVAILABLE for integrating whith Apache2"

    fi

}

: '
  @param String _APACHE_SUBSCRIPTION_NAME
  @param String _APACHE_SUBSCRIPTION_PATH
'
function apache_generate_vhost() {

  local _APACHE_SUBSCRIPTION_NAME=${1}
  local _APACHE_SUBSCRIPTION_PATH=${2}
  shift 2

  if [ -z ${_APACHE_SUBSCRIPTION_NAME:-} ]; then

    raise RequiredParameterNotFound "[apache_generate_vhost] Please provide a valid subscription name"

  fi

  if [ -z ${_APACHE_SUBSCRIPTION_PATH:-} ]; then

    raise RequiredParameterNotFound "[apache_generate_vhost] Please provide a valid subscription path"

  fi

  local _DOMAIN_LIST=${@}

  apache_prepare

  local _APACHE_SITE_CONFIG="${_APACHE_SITES_AVAILABLE}/${_APACHE_SUBSCRIPTION_NAME}.conf"
  cat <<EOF | tee ${_APACHE_SITE_CONFIG}
  <VirtualHost *:80>
    ServerName ${_APACHE_SUBSCRIPTION_NAME}.localhost
    ServerAlias ${_DOMAIN_LIST}
    DocumentRoot "${_APACHE_SUBSCRIPTION_PATH}"
    <Directory "${_APACHE_SUBSCRIPTION_PATH}">
      Options Indexes FollowSymLinks MultiViews
      AllowOverride All
      Order allow,deny
      allow from all
    </Directory>

    CustomLog /var/log/apache2/${_APACHE_SUBSCRIPTION_NAME}-access.log combined
    ErrorLog /var/log/apache2/${_APACHE_SUBSCRIPTION_NAME}-error.log
    LogLevel warn

  </VirtualHost>

  <virtualhost *:443>
    SSLEngine On
    SSLCertificateFile     /etc/ssl/certs/ssl-cert-snakeoil.pem
    SSLCertificateKeyFile  /etc/ssl/private/ssl-cert-snakeoil.key
    ServerName ${_APACHE_SUBSCRIPTION_NAME}.localhost
    ServerAlias ${_DOMAIN_LIST}
    DocumentRoot "${_APACHE_SUBSCRIPTION_PATH}"
    <Directory "${_APACHE_SUBSCRIPTION_PATH}">
      Options Indexes FollowSymLinks MultiViews
      AllowOverride all
      Order allow,deny
      allow from all
    </directory>
    ServerSignature On

    CustomLog /var/log/apache2/${_APACHE_SUBSCRIPTION_NAME}-ssl-access.log combined
    ErrorLog /var/log/apache2/${_APACHE_SUBSCRIPTION_NAME}-ssl-error.log
    LogLevel warn
  </virtualhost>

EOF
  out_success "Created file ${_APACHE_SITE_CONFIG}"
  out_info "Activating subscription virtual host [${_APACHE_SUBSCRIPTION_NAME}]" 1
  ${_A2ENSITE} ${_APACHE_SUBSCRIPTION_NAME}

}

: '
  @param String _APACHE_SUBSCRIPTION_INSTALATION_PATH $1
  @param String _APACHE_MACRO_VHOST_FILE $2
  @param List<string> _DOMAIN_LIST > $2 = $@
'
function apache_generate_vhost_macro() {

  local _APACHE_SUBSCRIPTION_INSTALATION_PATH=${1}
  local _APACHE_MACRO_VHOST_FILE=${2}
  shift 2

  if [ -z ${_APACHE_SUBSCRIPTION_INSTALATION_PATH:-} ]; then

    raise RequiredParameterNotFound "[apache_generate_vhost_macro] Please provide a valid subscription name"

  fi

  if [ -z ${_APACHE_MACRO_VHOST_FILE:-} ]; then

    raise RequiredParameterNotFound "[apache_generate_vhost_macro] Please provide a valid macro file configuration"

  fi

  local _APACHE_SUBSCRIPTION_PATH=$(dirname ${_APACHE_MACRO_VHOST_FILE:-})
  local _DOMAIN_LIST=${@}

  apache_prepare

  if [ ! -f "${_APACHE_MACRO_VHOST_FILE}" ]; then

    out_info "Creating virtual hosts file" 1
    touch "${_APACHE_MACRO_VHOST_FILE}"
    out_check_status $? "File updated ${_APACHE_MACRO_VHOST_FILE}" "[apache_generate_vhost] Error while on creating file in ${_APACHE_MACRO_VHOST_FILE}"

  fi

  out_info "Adding virtual hosts domains" 1

  for _HOSTNAME in ${_DOMAIN_LIST}; do

    local _MACRO="Use VHost ${_HOSTNAME}"
    local _MACRO_PATH="${_MACRO} ${_APACHE_SUBSCRIPTION_INSTALATION_PATH}"

    # Check if hostname exists in apache configuration file
    if (egrep -q "${_MACRO}" ${_APACHE_MACRO_VHOST_FILE}); then

      # If exists remove entries and add new entry
      if (! ${_GREP} -E "${_MACRO}" ${_APACHE_MACRO_VHOST_FILE} | ${_GREP} -E "${_APACHE_SUBSCRIPTION_INSTALATION_PATH}$" -q); then

        sed -i "/${_MACRO}/d" ${_APACHE_MACRO_VHOST_FILE}
        out_info "Updating domain ${_HOSTNAME} ${_APACHE_SUBSCRIPTION_INSTALATION_PATH}"
        cat <<EOF | tee -a ${_APACHE_MACRO_VHOST_FILE}  > /dev/null 2>&1
${_MACRO_PATH}
EOF
      out_check_status $? "Update domain ${_HOSTNAME} from file ${_APACHE_MACRO_VHOST_FILE} "  "Failed on update file: ${_APACHE_MACRO_VHOST_FILE} to hostname ${_HOSTNAME}"

      fi

    else

      # Add new entry on apache configuration file
      out_info "Registring domain ${_HOSTNAME} ${_APACHE_SUBSCRIPTION_INSTALATION_PATH}"
      cat <<EOF | tee -a ${_APACHE_MACRO_VHOST_FILE}  > /dev/null 2>&1
${_MACRO_PATH}
EOF
      out_check_status $? "Add domain ${_HOSTNAME} from file ${_APACHE_MACRO_VHOST_FILE} "  "Failed on registring domain ${_HOSTNAME} from file: ${_APACHE_MACRO_VHOST_FILE}"

    fi

  done

}

function apache_reload() {

  out_info "Reloading Apache" 1
  ${_SERVICE} apache2 reload
  out_check_status $? "Apache reloaded successfully" "Error on reload Apache"

}
