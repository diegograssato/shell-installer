#!/usr/bin/env bash


function file_sync_load_configurations() {

  if [ -z ${1:-} ]; then

    raise RequiredParameterNotFound "[file_sync_load_configurations] Please provide a valid operation: dl|up"

  else

    _LOCAL_SETUP_OPERATION=${1}

  fi

  if [ -z ${2:-} ]; then

    raise RequiredParameterNotFound "[file_sync_load_configurations] Please provide a valid subscription"

  else

    _LOCAL_SETUP_SUBSCRIPTION=${2}

  fi


    if [ -z ${3:-} ]; then

      _LOCAL_SETUP_SUBSCRIPTION_ENVIRONMENT="test"

    else

      _LOCAL_SETUP_SUBSCRIPTION_ENVIRONMENT=${3}

    fi

  if [ -z ${4:-} ]; then

    raise RequiredParameterNotFound "[file_sync_load_configurations] Please provide a valid site"

  else

    _LOCAL_SETUP_SUBSITE=${4}

  fi


  if [ -z ${5:-} ]; then

    _LOCAL_SETUP_SUBSITE_PATH=$(printf "/tmp/${_TASK_NAME}/%s/files/" ${_LOCAL_SETUP_SUBSITE})

  else

    _LOCAL_SETUP_SUBSITE_PATH=${5}

  fi


  [ ! -d ${_LOCAL_SETUP_SUBSITE_PATH} ] && ${_MKDIR} -p ${_LOCAL_SETUP_SUBSITE_PATH}
  out_warning "Loading configurations" 1

}


function file_sync_run_operations() {

  out_warning "Running operation '${_LOCAL_SETUP_OPERATION}'" 1
  case ${_LOCAL_SETUP_OPERATION} in
     "dl") site_configuration_files_download ${_LOCAL_SETUP_SUBSCRIPTION} ${_LOCAL_SETUP_SUBSCRIPTION_ENVIRONMENT} ${_LOCAL_SETUP_SUBSITE}  ${_LOCAL_SETUP_SUBSITE_PATH} "true" ;;
     "up") site_configuration_files_upload ${_LOCAL_SETUP_SUBSCRIPTION} ${_LOCAL_SETUP_SUBSCRIPTION_ENVIRONMENT} ${_LOCAL_SETUP_SUBSITE}  "${_LOCAL_SETUP_SUBSITE_PATH}/" "true" ;;
     *) raise OptionUnknown "Option '${_LOCAL_SETUP_OPERATION}' unknown.";
  esac

}
