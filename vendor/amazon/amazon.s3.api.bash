#!/usr/bin/env bash

################################################################################
# @param String _AMAZON_S3_FILEPATH_SOURCE - Local filepath to be uploaded
# @param String _AMAZON_S3_FILEPATH_DESTINATION - Remote filepath as destination
# @param String _AMAZON_S3_CONTENT_TYPE - Content-Type of the file
#
# Will upload into the configured bucket the file passed in as argument
################################################################################
function amazon_s3_upload() {

  local _AMAZON_S3_SOURCES="${1:-}"
  local _AMAZON_S3_CONTENT_TYPE="${2:-}"
  local _AMAZON_S3_FIRST_RESOURCE="${3:-}"


  if [[ -z ${_AMAZON_S3_SOURCES} ]]; then

    raise MissingRequiredConfig "[amazon_s3_upload] Please provider a valid source."

  fi

  for _AMAZON_S3_SOURCE in ${_AMAZON_S3_SOURCES}; do

    if [[ -d ${_AMAZON_S3_SOURCE} ]]; then

      [[ -z  ${_AMAZON_S3_FIRST_RESOURCE} ]] && local _AMAZON_S3_FIRST_RESOURCE=$(basename ${_AMAZON_S3_SOURCES})
       local _DIR="$(basename ${_AMAZON_S3_SOURCE})"
      if [[ ${_AMAZON_S3_FIRST_RESOURCE} == ${_DIR} ]]; then

         local _AMAZON_S3_FIRST_RESOURCE=${_DIR}

       else

         local _AMAZON_S3_FIRST_RESOURCE="${_AMAZON_S3_FIRST_RESOURCE}/$_DIR"

      fi

      amazon_s3_process_directory "${_AMAZON_S3_SOURCE}" "${_AMAZON_S3_CONTENT_TYPE}" "${_AMAZON_S3_FIRST_RESOURCE}"

    else


      amazon_s3_process_files "${_AMAZON_S3_SOURCE}" "${_AMAZON_S3_CONTENT_TYPE}" "${_AMAZON_S3_FIRST_RESOURCE}"

    fi

  done

}

function amazon_s3_process_directory() {

  local _AMAZON_S3_SOURCE="${1:-}"
  local _AMAZON_S3_CONTENT_TYPE="${2:-}"
  local _AMAZON_S3_FIRST_RESOURCE="${3:-}"

  local _AMAZON_S3_SOURCE_FILES="$(find ${_AMAZON_S3_SOURCE} -maxdepth 1 ! -path ${_AMAZON_S3_SOURCE})"
  amazon_s3_upload "${_AMAZON_S3_SOURCE_FILES}" "${_AMAZON_S3_CONTENT_TYPE}" "${_AMAZON_S3_FIRST_RESOURCE}"

}

function amazon_s3_process_files() {

  local _AMAZON_S3_SOURCES="${1:-}"
  local _AMAZON_S3_CONTENT_TYPE="${2:-}"
  local _AMAZON_S3_FIRST_RESOURCE="${3:-}"


  for _AMAZON_S3_SOURCE in ${_AMAZON_S3_SOURCES}; do

    if [[ -z ${_AMAZON_S3_CONTENT_TYPE} ]]; then

      local _AMAZON_S3_CONTENT_TYPE="$(file --mime-type -b ${_AMAZON_S3_SOURCE})"

    fi

    [[ ! -f ${_AMAZON_S3_SOURCE} ]] && continue

    amazon_s3_put "${_AMAZON_S3_SOURCE}" "${_AMAZON_S3_CONTENT_TYPE}" "${_AMAZON_S3_FIRST_RESOURCE}"

  done

}

function amazon_s3_put() {

  # Input
  local _AMAZON_S3_FILEPATH_SOURCE="${1:-}"
  local _AMAZON_S3_CONTENT_TYPE="${2-}"
  local _AMAZON_S3_FIRST_RESOURCE="${3:-}"

  if [ -z ${_AMAZON_S3_CONTENT_TYPE} ]; then

    raise MissingRequiredConfig "[amazon_s3_put] Please provider a valid Content-Type."

  fi

  if [ -z ${_AMAZON_S3_SECRET} ]; then

    raise MissingRequiredConfig "[amazon_s3_upload] Please provider a valid secret."

  fi

  if [ -z ${_AMAZON_S3_KEY} ]; then

    raise MissingRequiredConfig "[amazon_s3_upload] Please provider a valid key."

  fi

  if [ -z ${_AMAZON_S3_BUCKET} ]; then

    raise MissingRequiredConfig "[amazon_s3_upload] Please provider a valid bucket."

  fi

  if [ -z ${_AMAZON_S3_PROTOCOL} ]; then

    raise MissingRequiredConfig "[amazon_s3_upload] Please provider a valid destination."

  fi

  if [ -z ${_AMAZON_S3_URL} ]; then

    raise MissingRequiredConfig "[amazon_s3_upload] Please provider a valid domain."

  fi

  # Finally bucket
 local _FILENAME=$(basename ${_AMAZON_S3_FILEPATH_SOURCE})
 local _DIR="$(basename "$(dirname "${_AMAZON_S3_FILEPATH_SOURCE}")")"
 local _AMAZON_S3_BUCKET_DESTINATION="${_FILENAME}"

 [[ ! -z ${_AMAZON_S3_FIRST_RESOURCE} ]] && local _AMAZON_S3_BUCKET_DESTINATION="${_AMAZON_S3_FIRST_RESOURCE}/${_FILENAME}"

 local _AMAZON_S3_DESTINATION="${_AMAZON_S3_PROTOCOL}://${_AMAZON_S3_BUCKET}.${_AMAZON_S3_URL}/${_AMAZON_S3_BUCKET_DESTINATION}"

  # S3 assignatures
  local _AMAZON_S3_DATE=$(date -R)
  local _AMAZON_S3_STRINGTOSIGN="PUT\n\n${_AMAZON_S3_CONTENT_TYPE}\n${_AMAZON_S3_DATE}\n/${_AMAZON_S3_BUCKET}/${_AMAZON_S3_BUCKET_DESTINATION}"
  local _AMAZON_S3_SIGNATURE=$(echo -en ${_AMAZON_S3_STRINGTOSIGN} | openssl sha1 -hmac ${_AMAZON_S3_SECRET} -binary | base64)

  out_warning "Uploading [ ${_AMAZON_S3_FILEPATH_SOURCE} ] to [ ${_AMAZON_S3_DESTINATION} ]" 1

  ${_CURL} -X PUT -T "${_AMAZON_S3_FILEPATH_SOURCE}" \
    -H "Host: ${_AMAZON_S3_BUCKET}.${_AMAZON_S3_URL}" \
    -H "Date: ${_AMAZON_S3_DATE}" \
    -H "Content-Type: ${_AMAZON_S3_CONTENT_TYPE}" \
    -H "Authorization: AWS ${_AMAZON_S3_KEY}:${_AMAZON_S3_SIGNATURE}" \
    ${_AMAZON_S3_DESTINATION}

  out_check_status $? "File uploaded successfully." "Error while uploading file"

}


function amazon_s3_get() {

  # Input
  local _AMAZON_S3_FILEPATH_SOURCE="${1:-}"
  local _AMAZON_S3_FILEPATH_LOCAL="${2:-}"
  local _AMAZON_S3_CONTENT_TYPE="${3-}"

  if [ -z ${_AMAZON_S3_CONTENT_TYPE} ]; then

    raise MissingRequiredConfig "[amazon_s3_put] Please provider a valid Content-Type."

  fi

  if [ -z ${_AMAZON_S3_SECRET} ]; then

    raise MissingRequiredConfig "[amazon_s3_upload] Please provider a valid secret."

  fi

  if [ -z ${_AMAZON_S3_KEY} ]; then

    raise MissingRequiredConfig "[amazon_s3_upload] Please provider a valid key."

  fi

  if [ -z ${_AMAZON_S3_BUCKET} ]; then

    raise MissingRequiredConfig "[amazon_s3_upload] Please provider a valid bucket."

  fi

  if [ -z ${_AMAZON_S3_PROTOCOL} ]; then

    raise MissingRequiredConfig "[amazon_s3_upload] Please provider a valid destination."

  fi

  if [ -z ${_AMAZON_S3_URL} ]; then

    raise MissingRequiredConfig "[amazon_s3_upload] Please provider a valid domain."

  fi

  # Finally bucket
 local _FILENAME=$(basename ${_AMAZON_S3_FILEPATH_SOURCE})
  [[ -z ${_AMAZON_S3_FILEPATH_LOCAL} ]] && local _AMAZON_S3_FILEPATH_LOCAL="$(pwd)/${_FILENAME}"
  local _AMAZON_S3_BUCKET_DESTINATION="${_AMAZON_S3_FILEPATH_SOURCE}"

 local _AMAZON_S3_DESTINATION="${_AMAZON_S3_PROTOCOL}://${_AMAZON_S3_BUCKET}.${_AMAZON_S3_URL}/${_AMAZON_S3_FILEPATH_SOURCE}"

  # S3 assignatures
  local _AMAZON_S3_DATE=$(date -R)
  local _AMAZON_S3_STRINGTOSIGN="GET\n\n${_AMAZON_S3_CONTENT_TYPE}\n${_AMAZON_S3_DATE}\n/${_AMAZON_S3_BUCKET}/${_AMAZON_S3_BUCKET_DESTINATION}"
  local _AMAZON_S3_SIGNATURE=$(echo -en ${_AMAZON_S3_STRINGTOSIGN} | openssl sha1 -hmac ${_AMAZON_S3_SECRET} -binary | base64)

  out_warning "Downloading  [ ${_AMAZON_S3_DESTINATION} ] to [ ${_AMAZON_S3_FILEPATH_LOCAL} ]" 1

  ${_CURL} -H "Host: ${_AMAZON_S3_BUCKET}.${_AMAZON_S3_URL}" \
    -H "Date: ${_AMAZON_S3_DATE}" \
    -H "Content-Type: ${_AMAZON_S3_CONTENT_TYPE}" \
    -H "Authorization: AWS ${_AMAZON_S3_KEY}:${_AMAZON_S3_SIGNATURE}" \
    ${_AMAZON_S3_DESTINATION} -o ${_AMAZON_S3_FILEPATH_LOCAL}

  out_check_status $? "File uploaded successfully." "Error while uploading file"

}
