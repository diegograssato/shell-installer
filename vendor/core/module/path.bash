#!/usr/bin/env bash

## Expands a given path to its full path.
## If it has synlinks, it will be converted to the realpath.
## If it is a file, the path will also be expanded to realpath
## It does not return a trailling '/' for directories
## @param path - a path to be expanded
function path.expand () {
  local _DIR="$1" _FILE=""
  if [ -f "$1" ]; then
    _DIR="${1%/*}/"
    _FILE="${1/$_DIR/}"
  fi
  ( (
    if cd -P "$_DIR" &> /dev/null; then
      _REALPATH="$PWD/$_FILE"
      echo "${_REALPATH%/}"
    fi
  ) )
}

## Returns true if the passed path is a directory, false otherwise
## @param path - the path to be checked
function path.dir? () {
  test -d "$1"
}

## Returns true if the passed path is a file, false otherwise
## @param path - the path to be checked
function path.file? () {
  test -f "$1"
}

## Returns whether the path is a file
## @param path - the path to be checked
function path.block? () {
  test -b "$1"
}

## Returns whether the path is readable
## @param path - the path to be checked
function path.readable? () {
  test -r "$1"
}

## Returns whether the path is writable
## @param path - the path to be checked
function path.writable? () {
  test -w "$1"
}
## Returns whether the path is executable
## @param path - the path to be checked
function path.executable? () {
  test -x "$1"
}

## Returns whether the path is older than another path
## @param path - the path to be checked
## @param another_path - the path to be checked against
function path.older? () {
  test "$1" -ot "$2"
}

## Returns whether the path is newer than another path
## @param path - the path to be checked
## @param another_path - the path to be checked against
function path.newer? () {
  test "$1" -nt "$2"
}
