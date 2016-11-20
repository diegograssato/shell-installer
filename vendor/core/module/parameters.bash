#!/usr/bin/env bash

while getopts ":dyf" opt; do
  case $opt in
    d)
      _DEBUG=true
      echo "-d flag found! Debug is active. Please check the logfile: ${_DEVOPS_LOG_PATH}"
      ;;
    y)
      _FORCE_YES=1
      echo "-y flag found! Assuming YES to confirms"
      ;;
    f)
      _FULL_EXECUTION=1
      echo "-f flag found! Performing full execution"
      ;;
    \?)
      echo "Invalid flag: -$OPTARG"
      exit 1
      ;;
  esac
done

shift $(($OPTIND - 1)) # clean flags
#====================================================================================================#
