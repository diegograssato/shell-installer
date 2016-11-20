#!/usr/bin/env bash

function ctech_deploy_patches_create() {

  filesystem_create_folder ${_CTECH_DEPLOY_TEMP_PATCH_FOLDER}

  for _COMMIT in ${_CTECH_DEPLOY_GIT_COMMITS}; do

    git_create_patch ${_CTECH_DEPLOY_SUBSITE_PATH} ${_COMMIT} ${_CTECH_DEPLOY_TEMP_PATCH_FOLDER} ${_CTECH_DEPLOY_SUBSITE_NAME}
    ${_SED} -i "s#\(a\|b\)/src/#\1/docroot/sites/${_CTECH_DEPLOY_SUBSITE_NAME}/#g" "${_CTECH_DEPLOY_TEMP_PATCH_FOLDER}/${_COMMIT}.patch"

  done

}

function ctech_deploy_patches_apply() {

  for _COMMIT in ${_CTECH_DEPLOY_GIT_COMMITS}; do

    git_am ${_CTECH_DEPLOY_ACQUIA_SUBSCRIPTION_PATH} ${_COMMIT} ${_CTECH_DEPLOY_TEMP_PATCH_FOLDER} && true
    if [ $? -ge 1 ]; then

      out_warning "git am failed, aborting am session and will try to apply via patch afterwards" 1
      git_abort_am ${_CTECH_DEPLOY_ACQUIA_SUBSCRIPTION_PATH}
      git_apply_patch ${_CTECH_DEPLOY_ACQUIA_SUBSCRIPTION_PATH} ${_COMMIT} ${_CTECH_DEPLOY_TEMP_PATCH_FOLDER} && true

      if [ $? -ge 1 ]; then

        ctech_deploy_abort_script "ApplyPatchError" "It's not possible to apply this patch: ${_COMMIT}"

      fi

    fi

    out_success "Patch ${_COMMIT} applied with success" 1

  done

  out_info "Cleaning patches in ${_CTECH_DEPLOY_TEMP_PATCH_FOLDER}" 1
  # TODO filesystem_delete_file ${_CTECH_DEPLOY_TEMP_PATCH_FOLDER}

}
