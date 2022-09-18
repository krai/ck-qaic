#!/bin/bash

_INSTALL_SYSTEM_PACKAGES=${INSTALL_SYSTEM_PACKAGES:-yes}

echo "Running '$0' ..."
print_variables "${!_@}"
echo "Press Ctrl-C to break ..."
sleep 5

# Install system packages using apt.
echo "Installing system packages ..."
if [[ "${_INSTALL_SYSTEM_PACKAGES}" == "yes" ]]; then
  apt update -y
  apt upgrade -y
  apt install -y \
    git wget patch vim \
    libbz2-dev lzma libffi-dev \
    python3-dev python3-pip \
    lm-sensors ipmitool \
    ca-certificates curl gnupg lsb-release \
    acl \
    bc rsync cmake \
    htop tmux tree
  apt clean all
  exit_if_error "apt install failed!"
else
  echo "- skipping ..."
fi
