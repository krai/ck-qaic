#!/bin/bash

_PYTHON_VERSION=${PYTHON_VERSION:-3.9.13}
_GROUP=${GROUP:-krai}
_USER=${USER:-krai}
_USER_PASSWORD=${_USER_PASSWORD:-"oelinux123"}
_BASE_DIR=${BASE_DIR:-"/data"}
_TIMEZONE=${TIMEZONE:-"/Europe/London"}
_INSTALL_SYS_PACKAGE=${INSTALL_SYS_PACKAGE:-1}
_INSTALL_PYTHON=${INSTALL_PYTHON:-1}

. run_common.sh

echo "Running '$0'"
print_variables "${!_@}"

# Update the Repo URLs. (CentOS 8 has reached End of Life.)
cd /etc/yum.repos.d/
sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
cd

# Install system-level packages via 'yum'.
if [[ -z _INSTALL_SYS_PACKAGE ]]; then
  echo "Installing system packages."
  yum upgrade -y
  yum install -y make which patch vim git wget zip unzip openssl-devel bzip2-devel libffi-devel tmux epel-release
  yum install -y htop
  yum install -y dnf
  yum clean all
  # Install system-level packages via 'dnf'.
  dnf install -y libarchive cmake
  dnf install -y scl-utils
  dnf install -y gcc-toolset-11-gcc-c++
  exit_if_error "Failed to install system packages."
else
  echo "Passing system packages installation."
fi

# Install Python >= 3.7 from source.
if [[ -z _INSTALL_PYTHON ]]; then
#   export PYTHON_VERSION=${_PYTHON_MAJOR}.${_PYTHON_MINOR}.${_PYTHON_BATCH}
  echo "Installing Python ${_PYTHON_VERSION}"
  cd /usr/src \
  && wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${_PYTHON_VERSION}.tgz \
  && tar xzf Python-${_PYTHON_VERSION}.tgz \
  && rm -f Python-${_PYTHON_VERSION}.tgz \
  && cd /usr/src/Python-${_PYTHON_VERSION} \
  && ./configure --enable-optimizations && make -j8 altinstall \
  && rm -rf /usr/src/Python-${_PYTHON_VERSION}*
  exit_if_error "Failed to install Python ${_PYTHON_VERSION}."
else
  echo "Passing Python ${_PYTHON_VERSION} installation."
fi

# Create group 'qaic'.
groupadd -f qaic
# Create group 'krai'.
groupadd -f ${_GROUP}
# Create user 'krai'.
useradd -m -g ${_USER} -s /bin/bash -b ${_BASE_DIR} ${_USER}
# Add user 'krai' to some groups.
usermod -aG qaic,root,wheel ${_USER}
# Set user 'krai' password
echo ${_USER_PASSWORD} | passwd --stdin ${_USER}
# Do not ask user 'krai' for 'sudo' password.
echo "krai ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Fix permissions on the 'sudo' command.
chown root:root /usr/bin/sudo && chmod 4755 /usr/bin/sudo

# Set to local timezone (for power measurements).
rm /etc/localtime -f
ln -s /usr/share/zoneinfo"${_TIMEZONE}" /etc/localtime
date
