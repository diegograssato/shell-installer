#!/usr/bin/env bash

function mts_patches_create() {

  filesystem_create_folder ${_MTS_TEMP_PATCH_FOLDER}

  for _COMMIT in ${_MTS_GIT_COMMITS}; do

    git_create_patch ${_MTS_SUBSITE_PATH} ${_COMMIT} ${_MTS_TEMP_PATCH_FOLDER} ${_MTS_SUBSITE_NAME}
    ${_SED} -i "s#\(a\|b\)/src/#\1/docroot/sites/${_MTS_SUBSITE_NAME}/#g" "${_MTS_TEMP_PATCH_FOLDER}/${_COMMIT}.patch"

  done

}

function mts_patches_apply() {

  for _COMMIT in ${_MTS_GIT_COMMITS}; do

    if [ ${_MTS_INTERACTIVE} == true ]; then

      local _COMMIT_VIEW=$(${_MTS_RUN_GIT_SUBSITE} show --no-patch --oneline  --pretty=tformat:"%x1b[32m%h%x1b[0m%x20%s%x20%x1b[33m(%an - %cD)%x1b[0m" ${_COMMIT})
      out_confirm "Do you want to apply the patch: \n${_COMMIT_VIEW}" 1 && true
      if [ $? -ge 1 ]; then

        continue;

      fi

    fi

    git_apply_patch ${_MTS_ACQUIA_SUBSCRIPTION_PATH} ${_COMMIT} ${_MTS_TEMP_PATCH_FOLDER} && true
    if [ $? -ge 1 ]; then

      git_clean_to_head ${_MTS_ACQUIA_SUBSCRIPTION_PATH}
      out_warning "git apply patch failed, trying to apply via git am" 1
      git_am ${_MTS_ACQUIA_SUBSCRIPTION_PATH} ${_COMMIT} ${_MTS_TEMP_PATCH_FOLDER} && true
      if [ $? -ge 1 ]; then

        if [ ${_MTS_INTERACTIVE} == true ]; then

          out_warning "Problems encountered while applying the patch: \n${_COMMIT_VIEW}"
          out_confirm "Please resolve manually and continue. Continue?" 1 && true
          if [ $? -ge 1 ]  ; then

            mts_abort "ApplyPatchError" "Problem with patch not solved, aborting."

          fi

        else

          mts_abort "ApplyPatchError" "Problems to apply patch, aborting."

        fi

      fi

    fi

  done

  out_info "Cleaning patches in ${_MTS_TEMP_PATCH_FOLDER}" 1
  ${_RMF} ${_MTS_TEMP_PATCH_FOLDER}/*

}
