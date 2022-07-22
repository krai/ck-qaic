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

function get_os() {
  local os=$1
  local override=$2
  if [[ "${override}" == "yes" && ! -z "${os}" ]]; then
    echo "User overriding Device OS detection ..."
    _DEVICE_OS="${os}"
  else
    echo "Automatically detecting OS ..."
    if [[ $(cat /etc/os-release) == *Ubuntu* ]]; then
      _DEVICE_OS="ubuntu"
    else
      _DEVICE_OS="centos"
    fi
  fi
  echo "Setting Device OS as ${_DEVICE_OS}."
}