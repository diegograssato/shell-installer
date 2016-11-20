#!/usr/bin/env bash

function janrain_access_load_configurations() {

  if [ -z "${1:-}" ]; then

    raise RequiredParameterNotFound "[janrain_access_load_configurations] Please provide a valid email address"

  else

    _JANRAIN_ACCESS_EMAIL="${1}"

  fi

  if [ -z "${2:-}" ]; then

    _JANRAIN_ACCESS_ENTITLEMENT="false"

  else

    _JANRAIN_ACCESS_ENTITLEMENT="${2}"

  fi

  if [ -z "${3:-}" ]; then

    _JANRAIN_ACCESS_ROLE="false"

  else

    _JANRAIN_ACCESS_ROLE="${3}"

  fi

  if [ -z ${_JANRAIN_CLIENT_ID:-} ] || [ -z ${_JANRAIN_CLIENT_SECRET:-} ]; then

    raise RequiredConfigNotFound "[janrain_access_load_configurations] Please configure variables _JANRAIN_CLIENT_ID and _JANRAIN_CLIENT_SECRET in configuration file [config/janrain_config.bash]"

  fi

  if [ -z ${_JANRAIN_DOMAIN_URL:-} ]; then

    raise RequiredConfigNotFound "[janrain_access_load_configurations] Please configure variable _JANRAIN_DOMAIN_URL in configuration file [config/janrain_config.bash]"

  fi

  if [ -z "${_JQ}" ]; then

    raise RequiredDependencyNotFound "[janrain_access_load_configurations] Please install the jq command"

  fi

  out_warning "Loading configurations" 1

  if [ "${_JANRAIN_ACCESS_ENTITLEMENT}" == "false" ] || [ "${_JANRAIN_ACCESS_ROLE}" == "false" ]; then

    _JANRAIN_ACCESS_READONLY=true

  else

    _JANRAIN_ACCESS_READONLY=false

  fi

  # J&J SSO uses the default "user" entity type
  _JANRAIN_ACCESS_TYPE_NAME="user"
  _JANRAIN_ACCESS_FILTER="email='${_JANRAIN_ACCESS_EMAIL}'&attributes=[\"drupalRoles\",\"uuid\"]"

}

function janrain_access_fetch_user() {

  out_warning "Loading Drupal roles for [${_JANRAIN_ACCESS_EMAIL}]" 1

  _JANRAIN_ACCESS_USER_RESULT=$(janrain_entity_find ${_JANRAIN_CLIENT_ID} ${_JANRAIN_CLIENT_SECRET} ${_JANRAIN_ACCESS_TYPE_NAME} ${_JANRAIN_ACCESS_FILTER})
  # Mockup data, uncomment below
  # _JANRAIN_ACCESS_USER_RESULT='{"result_count":1,"results":[{"drupalRoles":{"con_emea_za_savlon_en":["administrator"],"con_na_us_cleanandclear_en":["administrator"],"con_na_us_lactaid_com":["administrator"],"con_na_ca_jbaby2_en":["administrator"],"con_emea_ru_motilium_ru":["administrator"],"con_na_ca_listerineprofessional_ca":["administrator"],"con_na_us_pepcid_com":["administrator"],"con_emea_ru_cleanandclear_ru":["administrator"],"con_na_ca_sudafed_ca":["administrator"],"con_emea_cz_imodium_cs":["administrator"],"con_na_us_motrin_com":["administrator"],"con_na_ca_helpthemquit_ca":["administrator"],"con_na_ca_womensrogaine_ca":["administrator"],"con_na_us_bengay_en":["administrator"],"con_na_us_sudafed_com":["administrator"],"con_na_ca_pepcid":["administrator"],"con_na_us_tylenol_com":["administrator"],"con_emea_ru_nizoral_ru":["administrator"],"con_emea_ru_imoflora_ru":["administrator"],"con_emea_ru_rinza_ru":["administrator"],"con_emea_sk_imodium_sk":["administrator"],"con_emea_ru_metrogyl_denta_ru":["administrator"],"con_na_us_desitin_en":["administrator"],"con_emea_ru_doktormom_ru":["administrator"],"con_na_us_neosporin_en":["administrator"],"con_emea_uk_benadryl_uk":["administrator"],"con_us_na_nizoral_en":["administrator"],"con_emea_uk_benylin_uk":["administrator"],"con_emea_es_regaine_es":["administrator"],"con_emea_uk_regaine_uk":["administrator"],"con_na_us_safetyandcarecommitment":["administrator"],"con_na_ca_visine_en":["administrator"],"con_emea_il_jbaby_en":["administrator"],"con_na_us_bandaidbrandfirstaid_com":["administrator"],"con_latam_cam_johnsonsbabycentroamerica_com":["administrator"],"con_na_ca_coldsorerelief_en":["administrator"],"con_na_ca_cleanandclear_ca":["administrator"],"product1":["administrator"],"con_us_na_jbaby_en":["administrator"],"con_na_us_reachfloss_com":["administrator"],"con_emea_sa_cleanandcleararabia_com":["administrator"],"con_na_ca_benylin_en":["administrator"],"con_aspac_au_jbaby_en":["administrator"],"con_na_us_benadryl":["administrator"],"con_na_us_nizoral_com":["administrator"],"con_emea_uk_caringeveryday_uk":["administrator"],"con_na_us_rhinocort":["administrator"],"con_na_us_imodium_com":["administrator"],"con_na_us_splendafoodservice_com":["administrator"],"con_na_us_mcneilproductrecall_com":["administrator"],"con_na_us_mcneilconsumer_com":["administrator"],"con_emea_be_perdolan_be":["administrator"],"con_na_us_zyrtec_com":["administrator"],"con_na_us_listerine_com_en":["administrator"],"con_na_ca_bandaid_en":["administrator"],"con_emea_uk_cleanandclear_uk":["administrator"],"con_na_ca_nicoderm_en":["administrator"],"con_emea_pl_listerine_pl":["administrator"],"con_na_ca_anusol_fr":["administrator"],"con_emea_uk_listerine_uk":["administrator"],"con_na_us_benecolusa_com":["administrator"],"con_na_ca_bandaid_fr":["administrator"],"con_emea_fr_actifed_fr":["administrator"],"con_latam_br_jbaby_pt_br":["administrator"],"con_na_us_rocskincare_com":["administrator"],"con_na_us_mcneilconsumer_en":["administrator"],"con_na_ca_anusol_en":["administrator"],"con_emea_es_frenadol":["administrator"],"con_latam_mx_johnsonsbaby_com_mx":["administrator"],"con_latam_es_johnsonsbaby_com_es":["administrator"],"con_na_us_bandaidfirstaid_en":["administrator"],"con_latam_ar_johnsonsbaby_com_ar":["administrator"],"con_emea_ru_hexoral_ru":["administrator"],"con_latam_co_johnsonsbaby_com_co":["administrator"],"con_emea_es_visine_es":["administrator"],"con_emea_ru_imodium_ru":["administrator"],"con_emea_de_imodium_de":["administrator"],"con_na_us_listerinepro_com":["administrator"],"con_emea_hu_imodium_hu":["administrator"],"con_na_ca_benylin_fr":["administrator"],"con_apac_au_listerine_com_au":["administrator"],"con_na_ca_tylenol_en":["administrator"],"con_emea_se_mcneilab_se":["administrator"],"con_aspac_ru_listerine_ru":["administrator"],"con_na_ca_visine_fr":["administrator"],"con_na_us_bandaid_en":["administrator"],"con_mena_com_imodium_mena":["administrator"],"con_na_ca_motrin2_fr":["administrator"],"con_na_us_healthyessentials_com":["administrator"]},"uuid":"82ddfbd8-4784-4ac8-bf2c-e2710c136a84"}],"stat":"ok"}'

  local _JANRAIN_ACCESS_USER_STAT=$(echo "${_JANRAIN_ACCESS_USER_RESULT}" | ${_JQ} '.stat')
  local _JANRAIN_ACCESS_USER_COUNT=$(echo "${_JANRAIN_ACCESS_USER_RESULT}" | ${_JQ} '.result_count')

  if [ "${_JANRAIN_ACCESS_USER_STAT}" == '"ok"' ] && [ "${_JANRAIN_ACCESS_USER_COUNT}" == "1" ]; then

    _JANRAIN_ACCESS_DRUPAL_ROLES=$(echo "${_JANRAIN_ACCESS_USER_RESULT}" | ${_JQ} -r '.results[].drupalRoles')
    _JANRAIN_ACCESS_UUID=$(echo "${_JANRAIN_ACCESS_USER_RESULT}" | ${_JQ} -r '.results[].uuid')

    out_success "User [${_JANRAIN_ACCESS_UUID}] found. Drupal roles assigned to it:"
    echo "${_JANRAIN_ACCESS_DRUPAL_ROLES}"

  else

    out_danger "Error while retrieving JanRain data" 1
    out_warning "${_JANRAIN_ACCESS_USER_RESULT}"
    # If user wasn't found, skip edit
    _JANRAIN_ACCESS_READONLY=true

  fi
}

function janrain_access_add_role() {

  if (! ${_JANRAIN_ACCESS_READONLY}); then

    out_warning "Checking if user already have assigned role" 1

    local _JANRAIN_ACCESS_ALREADY_ASSIGNED=""
    local _JANRAIN_ACCESS_CHECK_ENTITLEMENT=$(echo "${_JANRAIN_ACCESS_DRUPAL_ROLES}" | ${_JQ} -r ".${_JANRAIN_ACCESS_ENTITLEMENT}")

    if [ ! "${_JANRAIN_ACCESS_CHECK_ENTITLEMENT}" == "null" ]; then

      out_info "User already have data for entitlement [${_JANRAIN_ACCESS_ENTITLEMENT}]. Checking if same role is already assigned." 1
      _JANRAIN_ACCESS_ALREADY_ASSIGNED=$(echo "${_JANRAIN_ACCESS_DRUPAL_ROLES}" | ${_JQ} -r ".${_JANRAIN_ACCESS_ENTITLEMENT}[]" | grep -w "${_JANRAIN_ACCESS_ROLE}") && true

    fi

    if [[ "${_JANRAIN_ACCESS_ALREADY_ASSIGNED}" == "${_JANRAIN_ACCESS_ROLE}" ]]; then

      out_danger "User [${_JANRAIN_ACCESS_EMAIL}] is already assigned for role [${_JANRAIN_ACCESS_ROLE}] in entitlement [${_JANRAIN_ACCESS_ENTITLEMENT}]"

    else

      out_warning "Adding role [${_JANRAIN_ACCESS_ROLE}] to user [${_JANRAIN_ACCESS_EMAIL}] for entitlement [${_JANRAIN_ACCESS_ENTITLEMENT}]" 1

      # Add new entitlement/role to array
      local _JANRAIN_ACCESS_USER_NEW_ROLES=$(echo "${_JANRAIN_ACCESS_DRUPAL_ROLES}" | ${_JQ} -c ".${_JANRAIN_ACCESS_ENTITLEMENT} |= .+ [\"${_JANRAIN_ACCESS_ROLE}\"]")

      # Create a new attributes JSON with Drupal Roles key
      local _JANRAIN_ACCESS_ATTRIBUTES=$(${_JQ} -n -c ".drupalRoles |= .+ ${_JANRAIN_ACCESS_USER_NEW_ROLES}")

      # URL escape spaces so it can be posted
      local _JANRAIN_ACCESS_ATTRIBUTES_CONVERTED=$(echo ${_JANRAIN_ACCESS_ATTRIBUTES} | sed -e "s/ /%20/g")

      _JANRAIN_ACCESS_USER_UPDATE_RESULT=$(janrain_entity_update ${_JANRAIN_CLIENT_ID} ${_JANRAIN_CLIENT_SECRET} ${_JANRAIN_ACCESS_TYPE_NAME} ${_JANRAIN_ACCESS_UUID} ${_JANRAIN_ACCESS_ATTRIBUTES_CONVERTED})

      local _JANRAIN_ACCESS_USER_STAT=$(echo "${_JANRAIN_ACCESS_USER_UPDATE_RESULT}" | ${_JQ} '.stat')

      if [ "${_JANRAIN_ACCESS_USER_STAT}" == '"ok"' ]; then

        out_success "User saved successfully"

      else

        out_danger "Error while saving user"
        echo "${_JANRAIN_ACCESS_USER_UPDATE_RESULT}"

      fi

    fi

  fi

}
