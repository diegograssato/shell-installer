#!/usr/bin/env bash

function mtp_all_caches() {

  local _MTP_SITES=$(mtp_get_sites)
  if (${_MTP_PLATFORM_CODE_MODIFICATION}); then

    local _MTP_SITES=$(subscription_configuration_get_sites ${_MTP_SUBSCRIPTION})

  fi

  out_warning "Clearing all caches for ${_MTP_SITES// /, } in ${_MTP_SUBSCRIPTION}.${_MTP_ENVIRONMENT_PROD}" 1

  if [[ -z ${_MTP_SITES} ]]; then

    for _MTP_SITE in ${_MTP_SITES}; do

      acquia_clear_all_caches ${_MTP_SUBSCRIPTION} ${_MTP_ENVIRONMENT_PROD} ${_MTP_SITE}

    done

  else

    out_danger "No site found for cache cleaning" 1

  fi

}

function mtp_clear_varnish() {

  # Run only modification in .htaccess
  if [ ${_MTP_PLATFORM_CODE_MODIFICATION} == "false" ] && [ ${_MTP_DETECT_CODE_MODIFICATION_HTACCESS} == "true" ]; then

    local _MTP_SITES=$(subscription_configuration_get_sites ${_MTP_SUBSCRIPTION})
    out_warning "Clearing varnish cache for ${_MTP_SITES// /, } in ${_MTP_SUBSCRIPTION}.${_MTP_ENVIRONMENT_PROD}" 1

    if [[ -z ${_MTP_SITES} ]]; then

      for _MTP_SITE in ${_MTP_SITES}; do

        acquia_clear_varnish ${_MTP_SUBSCRIPTION} ${_MTP_ENVIRONMENT_PROD} ${_MTP_SITE}

      done

    else

      out_danger "No site found for cache cleaning" 1

    fi

  fi

}
