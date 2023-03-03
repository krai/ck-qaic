#!/bin/bash

_DEVICE_OS=${DEVICE_OS:-centos}
_DEVICE_OS_OVERRIDE=${DEVICE_OS_OVERRIDE:-no}
_DEVICE_GROUP=${DEVICE_GROUP:-krai}
_DEVICE_USER=${DEVICE_USER:-krai}
_DEVICE_BASE_DIR=${DEVICE_BASE_DIR:-/data}
_TIMEZONE=${TIMEZONE:-Europe/London}
_INSTALL_GITHUB_CLI=${INSTALL_GITHUB_CLI:-yes}
_INSTALL_PYTHON=${INSTALL_PYTHON:-yes}
_INSTALL_SYSTEM_PACKAGES=${INSTALL_SYSTEM_PACKAGES:-yes}
_PYTHON_VERSION=${PYTHON_VERSION:-${PYTHON_VER:-3.9.14}}
_PYTHON_VERSION_ARRAY=($(echo ${_PYTHON_VERSION} | tr "." " "))
_PYTHON_VERSION_MAJOR=${_PYTHON_VERSION_ARRAY[0]}
_PYTHON_VERSION_MINOR=${_PYTHON_VERSION_ARRAY[1]}
_PYTHON_VERSION_PATCH=${_PYTHON_VERSION_ARRAY[2]}

. common.sh

# Determine device OS.
get_os ${_DEVICE_OS} ${_DEVICE_OS_OVERRIDE}

# Print environment variables.
echo "Running '$0' ..."
print_variables "${!_@}"
echo
echo "Press Ctrl-C to break ..."
sleep 10

# Install system-wide dependencies.
INSTALL_SYSTEM_PACKAGES=${_INSTALL_SYSTEM_PACKAGES} INSTALL_GITHUB_CLI=${_INSTALL_GITHUB_CLI} . 1.run_as_root.${_DEVICE_OS}.sh

# Install Python >= 3.7, <= 3.9 from source.
if [[ "${_INSTALL_PYTHON}" == "yes" ]]; then
  echo "Installing Python v${_PYTHON_VERSION} ..."
  cd /usr/src \
  && wget https://www.python.org/ftp/python/${_PYTHON_VERSION}/Python-${_PYTHON_VERSION}.tgz \
  && tar xzf Python-${_PYTHON_VERSION}.tgz \
  && rm -f Python-${_PYTHON_VERSION}.tgz \
  && cd /usr/src/Python-${_PYTHON_VERSION} \
  && ./configure --enable-optimizations && make -j8 altinstall \
  && rm -rf /usr/src/Python-${_PYTHON_VERSION}*
  exit_if_error "Failed to install Python ${_PYTHON_VERSION}."
  # Make it the default Python 3. NB: On Heimdall, the default Python 3 is python3.5, not python3.6.
  update-alternatives --install /usr/bin/python3 python3 $(which python3.${_PYTHON_VERSION_MINOR})
else
  echo "Skipping Python v${_PYTHON_VERSION} installation ..."
fi
echo "Python 3:"
python3 --version

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

echo
echo "Done."
