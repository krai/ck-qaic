#!/bin/bash

_INSTALL_SYS_PACKAGE=${INSTALL_SYS_PACKAGE:-"yes"}

echo "Running '$0'"
print_variables "${!_@}"

# Update the Repo URLs. (CentOS 8 has reached End of Life.)
cd /etc/yum.repos.d/
sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
cd

# Install system-level packages via 'yum'.
if [[ "${_INSTALL_SYS_PACKAGE}" == "yes" ]]; then
  echo "Installing system packages."
  yum upgrade -y
  yum install -y make which patch vim git wget zip unzip openssl-devel bzip2-devel libffi-devel tmux epel-release
  yum install -y htop
  yum install -y dnf
  yum install -y lm_sensors
  yum clean all
  # Install system-level packages via 'dnf'.
  dnf install -y libarchive cmake
  dnf install -y scl-utils
  dnf install -y gcc-toolset-11-gcc-c++
  exit_if_error "Failed to install system packages."
else
  echo "Passing system packages installation."
fi