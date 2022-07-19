#!/bin/bash

_DEVICE_OS=${DEVICE_OS:-centos}
_PYTHON_VERSION=${PYTHON_VERSION:-3.9.13}
_DEVICE_GROUP=${DEVICE_GROUP:-krai}
_DEVICE_USER=${DEVICE_USER:-krai}
_DEVICE_BASE_DIR=${DEVICE_BASE_DIR:-"/data"}
_TIMEZONE=${TIMEZONE:-"Europe/London"}
_INSTALL_SYS_PACKAGE=${INSTALL_SYS_PACKAGE:-"yes"}
_INSTALL_PYTHON=${INSTALL_PYTHON:-"yes"}

. run_common.sh

echo "Running '$0'"
print_variables "${!_@}"

# Install OS dependencies
INSTALL_SYS_PACKAGE=${_INSTALL_SYS_PACKAGE} . 1.run_as_root.${_DEVICE_OS}.sh

# Install Python >= 3.7 from source.
if [[ "${_INSTALL_PYTHON}" == "yes" ]]; then
  echo "Installing Python ${_PYTHON_VERSION}."
  cd /usr/src \
  && wget https://www.python.org/ftp/python/${_PYTHON_VERSION}/Python-${_PYTHON_VERSION}.tgz \
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
groupadd -f ${_DEVICE_GROUP}
# Create user 'krai'.
useradd -m -g ${_DEVICE_USER} -s /bin/bash -b ${_DEVICE_BASE_DIR} ${_DEVICE_USER}
# Do not ask user 'krai' for 'sudo' password.
echo "krai ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Fix permissions on the 'sudo' command.
chown root:root /usr/bin/sudo && chmod 4755 /usr/bin/sudo

# Set to local timezone (for power measurements).
rm /etc/localtime -f
ln -s /usr/share/zoneinfo/"${_TIMEZONE}" /etc/localtime
date