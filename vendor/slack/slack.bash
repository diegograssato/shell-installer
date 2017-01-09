#!/usr/bin/env bash


function slack_prepare() {

    if [ -z ${_SLACK_TOKEN:-} ]; then

      raise MissingRequiredConfig "Please configure variable _SLACK_TOKEN for integrating whith Slack"

    fi

    if [ -z ${_SLACK_CHANNEL_DEFAULT:-} ]; then

      raise MissingRequiredConfig "Please configure variable _SLACK_CHANNEL_DEFAULT for integrating whith Slack"

    fi

    if [ -z ${_SLACK_TEAM:-} ]; then

      raise MissingRequiredConfig "Please configure variable _SLACK_TEAM for integrating whith Slack"

    fi
    local _SLACK_MSG_COUNT="$(echo ${1:-} | wc -w)"

    if [ ${_SLACK_MSG_COUNT} -eq 0 ]; then

      raise RequiredParameterNotFound "Please provide a message to be sent in Slack"

    else

      local _SLACK_MSG=${1}

    fi

    if [ ! -z ${2:-} ]; then

      local _SLACK_CHANNEL="#${2}"

    else

      local _SLACK_CHANNEL="#${_SLACK_CHANNEL_DEFAULT}"

    fi

    local _SLACK_USER="${SUDO_USER:-"$USER"}"

    if [ ! -z ${3:-} ]; then

      local _SLACK_ICON="${3}"

    else

      local _SLACK_ICON=":ghost:"

    fi

    _SLACK_MSG_TMP="$(mktemp -d "/tmp/slack-XXXXXX")"

    cat >"${_SLACK_MSG_TMP}/msg" <<EOF
    payload={
    "parse" :"full",
    "mrkdwn": true,
    "channel": "${_SLACK_CHANNEL}",
    "text": "${_SLACK_MSG}",
    "username": "${_SLACK_USER}",
    "icon_emoji": "${_SLACK_ICON}"
    }
EOF

}


function slack_notify() {

    slack_prepare "${@}"

    local _SLACK_WEBHOOK_URL="https://${_SLACK_TEAM}.slack.com/services/hooks/incoming-webhook?token=${_SLACK_TOKEN}"
    local _SLACK_INVITE_DATA=$(cat ${_SLACK_MSG_TMP}/msg)
    ${_CURL} --data-urlencode "${_SLACK_INVITE_DATA}" -s "${_SLACK_WEBHOOK_URL}" > /dev/null 2>&1

    if [ -d  ${_SLACK_MSG_TMP} ]; then

        ${_RM} -rf "${_SLACK_MSG_TMP}"
    fi

}
