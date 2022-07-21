#!/bin/bash

function exit_if_error() {
  if [ "${?}" != "0" ]; then
    echo ""
    echo "ERROR: $1"
    exit 1
  fi
}

function exit_if_empty() {
  if [ -z "$1" ]; then
    echo ""
    echo "ERROR: $2"
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