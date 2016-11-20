#!/usr/bin/env bash

import mysql drush

# @param String _DATABASE_SRC_DB_CONNECTION
# @param String _DATABASE_DST_DB_CONNECTION
function database_move() {

  local _DATABASE_SRC_DB_CONNECTION=${1:-}
	local _DATABASE_DST_DB_CONNECTION=${2:-}

	if [ -z "${_DATABASE_SRC_DB_CONNECTION}" ]; then

    raise RequiredParameterNotFound "[database_move] Please provide a valid database connection"

  fi

	if [ -z "${_DATABASE_DST_DB_CONNECTION}" ]; then

    raise RequiredParameterNotFound "[database_move] Please provide a valid database connection"

  fi

  local _DATABASE_TEMP_DB_FILE=$(mktemp /tmp/mysql_mysqldump-XXXXX.sql)
  mysql_mysqldump "${_DATABASE_SRC_DB_CONNECTION}" ${_DATABASE_TEMP_DB_FILE}

  if [ -s ${_DATABASE_TEMP_DB_FILE} ]; then

    mysql_mysql ${_DATABASE_TEMP_DB_FILE} "${_DATABASE_DST_DB_CONNECTION}"

  else

    raise DatabaseBackupError "The mysqldump failed to generate the backup. Error: ${_DATABASE_TEMP_DB_FILE}"

  fi

  ${_RM} ${_DATABASE_TEMP_DB_FILE}

  #TODO Or do it through sqlc
  #mysql_dump ${_DATABASE_SRC_DB_CONNECTION}
  #drush_sqlc_database_import

}

# @param String _SUBSITE_FOLDER
# @param String _FILE_SQL
function database_import() {

  local _SUBSITE_FOLDER=${1:-}
  local _FILE_SQL=${2:-}

  ${_CD} "${_SUBSITE_FOLDER}"
  drush_command "-y sql-drop"
  local _NODE_DIR="${_SUBSITE_FOLDER}/themes/*/node_modules/"
  # as per package.json, delete .info files to prevent error PDOException: SQLSTATE[23000]: Integrity constraint violation
  if [ -d "${_NODE_DIR}" ]; then
    ${_FIND} "${_NODE_DIR}" -name '*.info' -type f -delete
  fi

  ${_ZCAT} < ${_FILE_SQL} | drush_command "sqlc"

}
