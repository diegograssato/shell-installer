#!/usr/bin/env bash

function build_qa_site_create_subscription_sites_local() {

  out_info "Creating sites.local.php" 1

  local _SETTINGS_SUBSCRIPTION_CONFIG="${_BUILD_QA_SITE_APACHE_SUBSCRIPTION_PATH}/sites/sites.local.php"

  cat <<EOF | tee ${_SETTINGS_SUBSCRIPTION_CONFIG} > /dev/null
<?php
EOF

	# Generate site.local.php all subsites
	local _LIST_SUBSITES_IN_SUBSCRIPTION=$(subscription_configuration_get_sites ${_BUILD_QA_SITE_SUBSCRIPTION})
	for _SUB in ${_LIST_SUBSITES_IN_SUBSCRIPTION}; do

    local _SETTINGS_CONFIGURATION_GET_SUBSITE_NAME=$(site_configuration_get_subsite_name ${_SUB} ${_BUILD_QA_SITE_SUBSCRIPTION})
    local _DOMAIN_LIST=$(site_configuration_get_subsite_qa_domains ${_SUB} ${_BUILD_QA_SITE_SUBSCRIPTION})

    for _DOMAIN in ${_DOMAIN_LIST}; do

      cat <<EOF | tee -a ${_SETTINGS_SUBSCRIPTION_CONFIG}  > /dev/null 2>&1
\$sites['${_DOMAIN}'] = '${_SETTINGS_CONFIGURATION_GET_SUBSITE_NAME}';
EOF

    done

  done

	if [ -f "${_SETTINGS_SUBSCRIPTION_CONFIG}" ]; then

		out_success "Created file ${_SETTINGS_SUBSCRIPTION_CONFIG}"

	else

		out_danger "File ${_SETTINGS_SUBSCRIPTION_CONFIG} not found!"

	fi

}

function build_qa_site_create_subsite_settings() {

  out_info "Creating settings.local.php" 1

  local _SETTINGS_SITE_CONFIG="${_BUILD_QA_SITE_APACHE_SUBSITE_PATH}/settings.local.php"
  local _DATABASE_LOCAL_USER=$(site_configuration_get_subsite_database_user ${_BUILD_QA_SITE_SUBSITE} ${_BUILD_QA_SITE_SUBSCRIPTION}  ${_BUILD_QA_SITE_DB_DST})
  local _DATABASE_LOCAL_PASSWORD=$(site_configuration_get_subsite_database_password ${_BUILD_QA_SITE_SUBSITE} ${_BUILD_QA_SITE_SUBSCRIPTION}  ${_BUILD_QA_SITE_DB_DST})
  local _DATABASE_LOCAL_HOST=$(site_configuration_get_subsite_database_server ${_BUILD_QA_SITE_SUBSITE} ${_BUILD_QA_SITE_SUBSCRIPTION}  ${_BUILD_QA_SITE_DB_DST})
  local _DATABASE_LOCAL_DATABASE=$(site_configuration_get_subsite_database_name ${_BUILD_QA_SITE_SUBSITE} ${_BUILD_QA_SITE_SUBSCRIPTION}  ${_BUILD_QA_SITE_DB_DST})

  if [ -z "${_DATABASE_LOCAL_USER}" ] || [ -z "${_DATABASE_LOCAL_HOST}" ] || [ -z "${_DATABASE_LOCAL_DATABASE}" ]; then

    raise MissingQaDbSettings "[build_qa_site_create_subsite_settings] Please make sure the ${_BUILD_QA_SITE_DB_DST} database settings is configured in the yml file."

  fi

  cat <<EOF | tee ${_SETTINGS_SITE_CONFIG} > /dev/null 2>&1
<?php
\$conf['use_debug_theme'] = TRUE;
\$conf['apachesolr_read_only'] = "1";

\$databases['default']['default'] = array(
  'driver' => 'mysql',
  'database' => '${_DATABASE_LOCAL_DATABASE}',
  'username' => '${_DATABASE_LOCAL_USER}',
  'password' => '${_DATABASE_LOCAL_PASSWORD}',
  'host' => '${_DATABASE_LOCAL_HOST}',
  'prefix' => '',
  'collation' => 'utf8_general_ci',
);

unset(\$conf['cache_backends']);
unset(\$conf['cache_default_class']);
unset(\$conf['cache_class_cache_form']);
unset(\$conf['cache_class_cache_entity_bean']);

EOF

  if [ -f "${_SETTINGS_SITE_CONFIG}" ]; then

    out_success "Created file ${_SETTINGS_SITE_CONFIG}"

  else

    out_danger "File ${_SETTINGS_SITE_CONFIG} not found!"

  fi

}

#Generate apache vhost - development
function build_qa_site_list_domains() {

  if [ -z ${1:-} ]; then

    raise RequiredParameterNotFound "[build_qa_site_create_subsite_vhost] Please provide a valid site"

  else

    _BUILD_QA_SITE_SUBSITE=${1}

  fi

  out_info "[ ${_BUILD_QA_SITE_SUBSITE} ] - Domain List" 1

  local _BUILD_QA_SITE_DOMAIN_LIST=$(site_configuration_get_subsite_qa_domains ${_BUILD_QA_SITE_SUBSITE} ${_BUILD_QA_SITE_SUBSCRIPTION})

  for _DOMAINS_LIST in ${_BUILD_QA_SITE_DOMAIN_LIST}; do

      out_success "\thttp://${_DOMAINS_LIST}"

  done

}
