#!/usr/bin/env bash

function bootstrap_autoload() {

  for _FILE in $@; do

    if [ -n ${_FILE} ] && [ -f ${_FILE} ]; then # -n tests to see if the argument is non empty

      source ${_FILE}

    fi

  done

}

function bootstrap_init() {

  bootstrap_invoke_all "init"

}

function bootstrap_exit() {

  ${_RMF} ${_SF_STATIC_CACHE_BASE_FOLDER}
  bootstrap_invoke_all "exit"

  _DURATION=$SECONDS
  out_success "Execution time: $((${_DURATION} / 60))m $((${_DURATION} % 60))s" 1

}

function bootstrap_core() {

  _LOAD_FILES=$(find "${SF_SCRIPTS_HOME}/vendor/core" -type f -iname "*.sh" -o -iname "*.bash");
  bootstrap_autoload ${_LOAD_FILES}

}

function bootstrap_load_tasks() {

  _LOAD_FILES=$(find "${SF_SCRIPTS_HOME}/tasks" -type f -iname "$1.sh");
  if [ -z "${_LOAD_FILES}" ]; then

    raise FolderNotKnown "[bootstrap_load_tasks] Folder '${1}' is unknown"

  fi

  # Load also any bash files if available inside the task folder
  _LOAD_FILES=(${_LOAD_FILES[@]} $(find "${SF_SCRIPTS_HOME}/tasks/$1" -type f -iname "*.bash"));

  bootstrap_autoload ${_LOAD_FILES[@]}

}

function bootstrap_load_modules() {

  _VENDOR_FOLDER="${SF_SCRIPTS_HOME}/vendor"
  _FOLDER_MODULES_LOCAL="${SF_SCRIPTS_HOME}/modules"

  while [[ ! -z "${_MODULE_DEPENDENCIES:-}" && -n "${_MODULE_DEPENDENCIES[@]}" && "${#_MODULE_DEPENDENCIES[@]}" -ge 1 && -n "${#_LOADED_MODULE_DEPENDENCIES[@]}" ]]; do

    _FOLDERS=("")
    for _FOLDER in ${_MODULE_DEPENDENCIES[@]}; do

      _ERRORS_FOUND=false

      if [ -d "${_VENDOR_FOLDER}/${_FOLDER}" ]; then

        _FOLDERS=(${_FOLDERS[@]} "${_VENDOR_FOLDER}/${_FOLDER}")

      else

          if [ -d "${_FOLDER_MODULES_LOCAL}/${_FOLDER}" ]; then

            _FOLDERS=(${_FOLDERS[@]} "${_FOLDER_MODULES_LOCAL}/${_FOLDER}")

          else

            _ERRORS_FOUND=true

          fi

          if [ ${_ERRORS_FOUND} == true ];then

              raise FolderNotKnown "[bootstrap_load_modules] Folder '${_FOLDER_MODULES_LOCAL}/${_FOLDER}' is unknown"

          fi

      fi

    done

    _LOAD_FILES=$(find ${_FOLDERS[@]} -not \( -path "${SF_SCRIPTS_HOME}/vendor/core" -prune \) -type f -iname "*.bash");
    _LOADED_MODULE_DEPENDENCIES_BATCH=(${_MODULE_DEPENDENCIES[@]})

    bootstrap_autoload ${_LOAD_FILES}
    if [ ! -z ${_LOADED_MODULE_DEPENDENCIES_BATCH:-} ]; then

      bootstrap_update_loaded_files ${_LOADED_MODULE_DEPENDENCIES_BATCH[@]}

    fi

  done

  # Load config variables from dependencies
  for _MODULE in ${_LOADED_MODULE_DEPENDENCIES[@]}; do

      local _CONFIG_PATH="${SF_SCRIPTS_HOME}/config/${_MODULE}_config.bash"
      bootstrap_autoload ${_CONFIG_PATH}

  done

  # Load config variables from running task
  local _TASK_CONFIG_PATH="${SF_SCRIPTS_HOME}/config/${_TASK_NAME}_config.bash"
  bootstrap_autoload ${_TASK_CONFIG_PATH}

}

function bootstrap_update_loaded_files() {

  for _MODULE in ${@}; do

    if ! in_array? ${_MODULE} _LOADED_MODULE_DEPENDENCIES; then

      _LOADED_MODULE_DEPENDENCIES=(${_LOADED_MODULE_DEPENDENCIES[@]} $_MODULE)

      _TEMP_DEPENDENCY_LIST=(${_MODULE_DEPENDENCIES[@]/$_MODULE})

      if [ ! -z ${_TEMP_DEPENDENCY_LIST:-} ]; then

        _MODULE_DEPENDENCIES=(${_TEMP_DEPENDENCY_LIST[@]})

      else

        _MODULE_DEPENDENCIES=()

      fi

    fi

  done

}

function bootstrap_update() {

  system_check_update
  system_check_dependencies_not_installed

}

function bootstrap_run() {

  # Shift task name parameter
  shift

  bootstrap_init

  #Check missing require configurations
  if is_function? "${_TASK_NAME}_configurations"; then

    "${_TASK_NAME}_configurations"

  fi

  # Validate usage if available. Otherwise, just execute
  if ! is_function? "${_TASK_NAME}_usage" || (is_function? "${_TASK_NAME}_usage" && "${_TASK_NAME}_usage" "$@"); then

    if is_function? "${_TASK_NAME}_run"; then

      "${_TASK_NAME}_run" "$@"

    else

      raise RunFunctionNotFound "[bootstrap_run] Task '${_TASK_NAME}' did not implement the run function"

    fi

  else

    raise InvalidTaskUsage "[bootstrap_run] Task usage is invalid for task '${_TASK_NAME}'"

  fi

}

function bootstrap_invoke_all() {

  local _BOOTSTRAP_HOOK="${1:-}"
  shift 1
  local _BOOTSTRAP_HOOK_PARAMS="${@}"

  for _MODULE in "${_LOADED_MODULE_DEPENDENCIES[@]}"; do

    if (is_function? "${_MODULE}_${_BOOTSTRAP_HOOK}" ); then

      "${_MODULE}_${_BOOTSTRAP_HOOK}" ${_BOOTSTRAP_HOOK_PARAMS}

    fi

  done

}
