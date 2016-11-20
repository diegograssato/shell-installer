#!/usr/bin/env bash

: '
  @param String  _DATABASE_SRC_DB_CONNECTION formatted string for mysql connection
  @return String _DATABASE_TEMP_DB_FILE path to temporary file with db dump or empty
'
function mysql_mysqldump() {

  local _DATABASE_DB_CONNECTION=${1:-}
  local _DATABASE_TEMP_DB_FILE=${2:-}

  if [ -z "${_DATABASE_DB_CONNECTION}" ]; then

    raise RequiredParameterNotFound "[mysql_mysqldump] Please provide a valid MySQL connection string"

  fi

  if [ -z "${_DATABASE_TEMP_DB_FILE}" ]; then

    raise RequiredParameterNotFound "[mysql_mysqldump] Please provide a valid temporary file, use mktemp"

  fi

  if (mysql_validate_connection "${_DATABASE_DB_CONNECTION}"); then

    out_info "Backing up ${_DATABASE_DB_CONNECTION} into ${_DATABASE_TEMP_DB_FILE}" 1

    ${_MYSQLDUMP} $(echo "${_DATABASE_DB_CONNECTION}") > $(echo ${_DATABASE_TEMP_DB_FILE})

    out_success "mysqldump backup file generated successfully to ${_DATABASE_TEMP_DB_FILE}"

    if [ ! -s ${_DATABASE_TEMP_DB_FILE} ]; then

      raise MysqlDumpFail "[mysql_mysqldump] Error while generating backup"

    fi

  fi

}

: ' Function that restores a sql backup file into a mysql connection.
  @param String  _DATABASE_TEMP_DB_FILE path to temporary file with db dump
  @param String  _DATABASE_SRC_DB_CONNECTION formatted string for mysql connection
'
function mysql_mysql() {

  local _DATABASE_TEMP_DB_FILE=${1:-}
  local _DATABASE_DB_CONNECTION=${2:-}

  if [ ! -s ${_DATABASE_TEMP_DB_FILE} ]; then

    raise RequiredParameterNotFound "Please provide a valid MySQL backup file"

  fi

  if [ -z "${_DATABASE_DB_CONNECTION}" ]; then

    raise RequiredParameterNotFound "Please provide a valid MySQL connection string"

  fi

  if (mysql_validate_connection "${_DATABASE_DB_CONNECTION}"); then

    mysql_drop "${_DATABASE_DB_CONNECTION}"

    out_info "Restoring MySQL dump ${_DATABASE_TEMP_DB_FILE} into ${_DATABASE_DB_CONNECTION}" 1
    ${_MYSQL} $(echo "${_DATABASE_DB_CONNECTION}") < $(echo ${_DATABASE_TEMP_DB_FILE})

  fi

}

: ' Validates if a database exists and if connection works
  @param String  _DATABASE_CONNECTION formatted string for mysql connection
'
function mysql_validate_connection() {

  local _DATABASE_CONNECTION=${1:-}

  if [ -z "${_DATABASE_CONNECTION}" ]; then

    raise RequiredParameterNotFound "[mysql_validate_connection] Please provide a valid MySQL connection string"

  fi

  local _DATABASE=$(echo ${_DATABASE_CONNECTION} | ${_SED} "s/-[^[:space:]]*//g" | ${_SED} "s/\s*//g")

  out_info "Checking connection with ${_DATABASE}"

  local _MYSQLSHOW_DATABASE=$(${_MYSQLSHOW} $(echo "${_DATABASE_CONNECTION}") | ${_GREP} -v Wildcard | ${_GREP} -o ${_DATABASE})

  if [ "${_MYSQLSHOW_DATABASE}" == "${_DATABASE}" ]; then

    out_success "Successfully connected to ${_DATABASE_CONNECTION}"

  else

    raise DatabaseConnectionProblem "[mysql_validate_connection] Problems with ${_DATABASE_CONNECTION}. Please check if host or database exists"

  fi

}

function mysql_drop() {

  local _DATABASE_CONNECTION=${1:-}

  if [ -z "${_DATABASE_CONNECTION}" ]; then

    raise RequiredParameterNotFound "[mysql_validate_connection] Please provide a valid MySQL connection string"

  fi

  out_info "Dropping tables from ${_DATABASE_CONNECTION}"

  local _MYSQL_SHOW_TABLES=$(${_MYSQL} ${_DATABASE_CONNECTION} -s -e "SHOW TABLES;")
  local _MYSQL_COMMAND_BULK_DROP=""

  for _TABLE in ${_MYSQL_SHOW_TABLES}; do

    local _MYSQL_COMMAND="DROP TABLE ${_TABLE};";
    _MYSQL_COMMAND_BULK_DROP="${_MYSQL_COMMAND_BULK_DROP} ${_MYSQL_COMMAND}";

  done

  ${_MYSQL} ${_DATABASE_CONNECTION} -s -e "${_MYSQL_COMMAND_BULK_DROP}"

}
