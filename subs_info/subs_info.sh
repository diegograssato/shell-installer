#!/usr/bin/env bash

# TODO change echos to out_file to start building the yml report

import drush yml_loader
import site_configuration subscription_configuration

function subs_info_run() {

  subs_info_load_configurations "${@}"

  subs_info_check_subscriptions

  subs_info_post_execution

}
