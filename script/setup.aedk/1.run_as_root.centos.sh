#!/bin/bash

_INSTALL_SYSTEM_PACKAGES=${INSTALL_SYSTEM_PACKAGES:-yes}
_INSTALL_GITHUB_CLI=${INSTALL_GITHUB_CLI:-yes}

echo "Running '$0' ..."
print_variables "${!_@}"
echo "Press Ctrl-C to break ..."
sleep 5

# Update the repos URLs. (CentOS 8 has reached End of Life.)
cd /etc/yum.repos.d/
sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
cd

# Install system-level packages via 'yum' and 'dnf'.
echo "Installing system packages ..."
if [[ "${_INSTALL_SYSTEM_PACKAGES}" == "yes" ]]; then
  # Install system-level packages via 'yum'.
  yum upgrade -y
  yum install -y make which patch vim git wget zip unzip openssl-devel bzip2-devel xz-devel libffi-devel tmux epel-release
  yum install -y htop lm_sensors
  yum install -y dnf
  yum clean all
  exit_if_error "Failed to install system packages via yum!"
  # Install system-level packages via 'dnf'.
  dnf install -y libarchive cmake
  dnf install -y scl-utils
  dnf install -y gcc-toolset-11-gcc-c++
  exit_if_error "Failed to install system packages via dnf!"
else
  echo "- skipping ..."
fi

# Install GitHub's Command Line Interface (CLI).
echo "Installing GitHub CLI ..."
if [[ "${_INSTALL_GITHUB_CLI}" == "yes" ]]; then
  dnf install 'dnf-command(config-manager)'
  dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
  dnf install gh
fi
