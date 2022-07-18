#!/bin/bash

function exit_if_error() {
  if [ "${?}" != "0" ]; then
    echo ""
    echo "ERROR: $1"
    exit 1
  fi
}

function print_variables() {
  a=("$@")
  echo $a
  unset a[0]
  for var in "${a[@]}"; do
    printf "Setting %s%q\n" "${var:1}=" "${!var}"
  done
}

function contains_element () {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}