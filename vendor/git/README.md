function git_load_repositories ${_GIT_REPO_URL} ${_GIT_REPO_RESOURCE} ${_GIT_REPO_PATH}

function git_clone ${_GIT_REPO_URL} ${_GIT_REPO_PATH}

function git_update ${_GIT_REPO_PATH}

function git_checkout ${_GIT_REPO_RESOURCE} ${_GIT_REPO_PATH}

function git_checkout_new_branch ${_GIT_REPO_PATH} ${_GIT_BRANCH}

function git_reset_repository ${_GIT_REPO_PATH}

function git_clean_repository ${_GIT_REPO_PATH}

function git_list_commits_by_filter ${_GIT_REPO_RESOURCE} ${_GIT_REPO_PATH} ${_GIT_FILTER}

function git_create_patch ${_GIT_REPO_PATH} ${_GIT_COMMIT} ${_GIT_PATCH_FOLDER}

function git_am ${_GIT_REPO_PATH} ${_GIT_COMMIT} ${_GIT_PATCH_FOLDER}

function git_apply_patch ${_GIT_REPO_PATH} ${_GIT_COMMIT} ${_GIT_PATCH_FOLDER}

function git_commit_all ${_GIT_REPO_PATH} ${_GIT_SUBJECT} (${_GIT_AUTHOR})

function git_push_in_branch ${_GIT_REPO_PATH} ${_GIT_REPO_BRANCH}

function git_abort_am ${_GIT_REPO_PATH}

function git_is_current_resource_a_tag ${_GIT_REPO_PATH}

function git_tag ${_GIT_REPO_PATH} ${_GIT_TAG_RESOURCE}

function git_generate_new_tag_name ${_GIT_REPO_PATH} ${_GIT_ACTIVE_RESOURCE}
