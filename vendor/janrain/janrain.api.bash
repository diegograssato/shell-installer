#!/usr/bin/env bash

function janrain_entity_find() {

  local _JANRAIN_CLIENT_ID=${1}
  local _JANRAIN_CLIENT_SECRET=${2}
  local _JANRAIN_TYPE_NAME=${3}
  local _JANRAIN_FILTER=${4}
  local _JANRAIN_CONTENT_TYPE="application/x-www-form-urlencoded"

  local _JANRAIN_PARAMS="type_name=${_JANRAIN_TYPE_NAME}&filter=${_JANRAIN_FILTER}"

  janrain_entity ${_JANRAIN_CLIENT_ID} ${_JANRAIN_CLIENT_SECRET} ${_JANRAIN_CONTENT_TYPE} ${_JANRAIN_PARAMS} "entity.find"

}

function janrain_entity_update() {

  local _JANRAIN_CLIENT_ID=${1}
  local _JANRAIN_CLIENT_SECRET=${2}
  local _JANRAIN_TYPE_NAME=${3}
  local _JANRAIN_UUID=${4}
  local _JANRAIN_ATTRIBUTES=${5}
  local _JANRAIN_CONTENT_TYPE="application/json"

  local _JANRAIN_POST_DATA="type_name=${_JANRAIN_ACCESS_TYPE_NAME}&uuid=${_JANRAIN_UUID}&attributes=${_JANRAIN_ATTRIBUTES}"

  janrain_entity ${_JANRAIN_CLIENT_ID} ${_JANRAIN_CLIENT_SECRET} ${_JANRAIN_CONTENT_TYPE} ${_JANRAIN_POST_DATA} "entity.update"

}
