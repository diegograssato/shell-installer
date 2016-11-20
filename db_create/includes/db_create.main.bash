#!/usr/bin/env bash

function db_create_load_configurations() {

  if [ -z "${1:-}" ]; then

    raise RequiredParameterNotFound "[db_create_load_configurations] Please provide a valid email address"

  else

    _DB_CREATE_NAME="${1}"

  fi

  if [ -z "${2:-}" ]; then

    raise RequiredParameterNotFound "[db_create_load_configurations] Please provide a valid email address"

  else

    _DB_CREATE_SERVER="${2}"
    _DB_CREATE_SERVER_VAR=$(echo ${_DB_CREATE_SERVER^^} | sed 's/\W//g')

  fi

  # Mysql Variables
  _DB_CREATE_SERVER_USER=$(printf "_DB_CREATE_USER_%s" ${_DB_CREATE_SERVER_VAR})
  _DB_CREATE_SERVER_PASS=$(printf "_DB_CREATE_PASS_%s" ${_DB_CREATE_SERVER_VAR})

  # SHH Variables
  _DB_CREATE_SSH_SERVER_USER=$(printf "_DB_CREATE_SSH_USER_%s" ${_DB_CREATE_SERVER_VAR})
  _DB_CREATE_SSH_SERVER_PASS=$(printf "_DB_CREATE_SSH_PASS_%s" ${_DB_CREATE_SERVER_VAR})

}

function db_create_create_database() {

  out_warning "Creating database [${_DB_CREATE_NAME}] on server [${_DB_CREATE_SERVER}]" 1

  local _DB_CREATE_MYSQL_COMMAND="${_MYSQL} -u${!_DB_CREATE_SERVER_USER} -p${!_DB_CREATE_SERVER_PASS} -h${_DB_CREATE_SERVER}"
  local _DB_CREATE_MYSQL_REMOTE_COMMAND="${_MYSQL} -u${!_DB_CREATE_SERVER_USER} -p${!_DB_CREATE_SERVER_PASS}"

  local _DB_CREATE_SSH_CONECTION="sshpass -p ${!_DB_CREATE_SSH_SERVER_PASS} ssh ${!_DB_CREATE_SSH_SERVER_USER}@${_DB_CREATE_SERVER}"
  local _DB_CREATE_DATABASE_COMMAND="
    CREATE DATABASE IF NOT EXISTS ${_DB_CREATE_NAME};
  "

  local _DB_CREATE_DATABASE_PERMISSION_COMMAND="
    GRANT ALL ON ${_DB_CREATE_NAME}.* to open_solutions@'%' identified by 'open_solutions'; GRANT ALL ON ${_DB_CREATE_NAME}.* to open_solutions@'localhost' identified by 'open_solutions';FLUSH PRIVILEGES;
  "

  ${_DB_CREATE_MYSQL_COMMAND} -e "${_DB_CREATE_DATABASE_COMMAND}" >/dev/null 2>&1 && true
  if [ $? -ne 0 ]; then


    if (service_check_status ${_DB_CREATE_SERVER} 22); then

      out_warning "Remote database creation failed. Will try to create through SSH."
      ${_DB_CREATE_SSH_CONECTION} <<ENDSSH
        echo -e "\n${BBLUE}[$(date +%H:%M:%S)][ * ] Creating DB if not exists${COLOR_OFF}"
        echo "${_DB_CREATE_DATABASE_COMMAND}" | ${_DB_CREATE_MYSQL_REMOTE_COMMAND}
        echo -e "\n${BBLUE}[$(date +%H:%M:%S)][ * ] Adding grants to open_solutions user ${COLOR_OFF}"
        echo "${_DB_CREATE_DATABASE_PERMISSION_COMMAND}" | ${_DB_CREATE_MYSQL_REMOTE_COMMAND}
        echo -e "\n${BBLUE}[$(date +%H:%M:%S)][ * ] Privileges flushed successfully${COLOR_OFF}"

ENDSSH

    else

      raise ServerNotFound "Server ${_DB_CREATE_SERVER} in the port 22"

    fi

  else

    if (service_check_status ${_DB_CREATE_SERVER} 3306); then

      out_success "Database created successfully"

      out_info "Creating DB if not exists"
      echo "${_DB_CREATE_DATABASE_COMMAND}" |  ${_DB_CREATE_MYSQL_COMMAND} && true
      out_check_status $? "Database created successfully" "Error while creating database"

      out_info "Adding grants to open_solutions user"
      echo "${_DB_CREATE_DATABASE_PERMISSION_COMMAND}"  |  ${_DB_CREATE_MYSQL_COMMAND} && true
      out_check_status $? "Grants created successfully" "Error while creating grants"


    else

      raise ServerNotFound "Server ${_DB_CREATE_SERVER} in the port 3306"

    fi
  fi


}
