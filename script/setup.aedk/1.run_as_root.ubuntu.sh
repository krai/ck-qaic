#!/bin/bash

_USER=${USER:-krai}
_INSTALL_SYS_PACKAGE=${INSTALL_SYS_PACKAGE:-"yes"}

echo "Running '$0'"
print_variables "${!_@}"

# Install system packages using apt.
if [[ "${_INSTALL_SYS_PACKAGE}" == "yes" ]]; then
  echo "Installing system packages."
  sudo apt update -y
  sudo apt upgrade -y
  sudo apt install -y \
    git wget patch vim \
    libbz2-dev lzma \
    python3-dev python3-pip \
    lm-sensors ipmitool \
    ca-certificates curl gnupg lsb-release \
    acl
  sudo apt clean all
  exit_if_error "apt install failed!"
else
  echo "Passing system packages installation."
fi

# Add user 'krai' to some groups.
usermod -aG qaic,sudo ${_USER}
groups krai
# Do not ask user 'krai' for 'sudo' password.
echo "krai ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
