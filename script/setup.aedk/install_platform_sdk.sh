#!/bin/bash

ARCH=$(uname -m)
_ARCH="aarch64"
if [[ "${ARCH}" != "${_ARCH}" ]]; then
  echo "ERROR: This script must be run on '${_ARCH}', not '${ARCH}'!"
  exit 1
fi	

if [[ $(cat /etc/os-release) == *Ubuntu* ]]; then
  _OS="ubuntu"
else
  _OS="centos"
fi

_DEVICE_BASE_DIR=${DEVICE_BASE_DIR:-/home}
_DEVICE_USER=${DEVICE_USER:-krai}
_DEVICE_GROUP=${DEVICE_GROUP:-krai}

_SDK_DIR=${SDK_DIR:-"${_DEVICE_BASE_DIR}/${_DEVICE_USER}"}
_SDK_VER=${SDK_VER:-1.7.1.12}

_PLATFORM_SDK=${PLATFORM_SDK:-"${_SDK_DIR}/qaic-platform-sdk-${_ARCH}-${_OS}-${_SDK_VER}.zip"}
echo ${_PLATFORM_SDK}
if [[ ! -f "${_PLATFORM_SDK}" ]]; then
  _PLATFORM_SDK="${_SDK_DIR}/qaic-platform-sdk-${_SDK_VER}.zip"
fi
if [[ ! -f "${_PLATFORM_SDK}" ]]; then
  echo "ERROR: File '${_PLATFORM_SDK}' does not exist!"
  exit 1
fi
echo "Using Platform SDK: ${_PLATFORM_SDK}"

unzip -o ${_PLATFORM_SDK} -d "$(dirname ${_PLATFORM_SDK})"
cd "$(dirname ${_PLATFORM_SDK})/qaic-platform-sdk-${_SDK_VER}/${_ARCH}/${_OS}"

# Devices with perf kernel.
if [[ $(uname -r) == *perf ]]; then
  _DEVICE_MODEL=$(cat /proc/device-tree/model | tr -d '\0')
  # Ubuntu-based devices: Gloria (ends with 'Gloria'), RB6 (contains 'RB6'), EB6 (ends with 'RB6').
  if [[ ${_OS} == ubuntu ]] && [[ ${_DEVICE_MODEL} == *Gloria || ${_DEVICE_MODEL} == *RB6* ]]; then
    echo "yes" | rm deb/qaic-kmd_${_SDK_VER}_arm64.deb
    cp deb-perf/qaic-kmd_${_SDK_VER}_arm64.deb deb/
  fi
  # CentOS-based devices: Haishen (*HDK), Heimdall (*AEDK).
  if [[ ${_OS} == "centos" ]] && [[ ${_DEVICE_MODEL} == *DK ]]; then
    echo "yes" | rm rpm/qaic-kmd-${_SDK_VER}-1.el7.${_ARCH}.rpm
    cp rpm-perf/qaic-kmd-${_SDK_VER}-1.el7.${_ARCH}.rpm rpm/
  fi
fi
echo "yes" | sudo ./uninstall.sh
sudo ./install.sh

# Create dir for logs, writable by user group.
_LOGS_DIR=${LOGS_DIR:-/opt/qti-aic/logs}
sudo mkdir -p ${_LOGS_DIR}
sudo chgrp ${_DEVICE_GROUP} ${_LOGS_DIR}
sudo chmod g+ws ${_LOGS_DIR}
sudo setfacl -R -d -m group:${_DEVICE_GROUP}:rw ${_LOGS_DIR}

# Add user to 'qaic' group.
sudo usermod -aG qaic ${_DEVICE_USER}

# Make version utility executable by 'qaic' group.
sudo chgrp qaic /opt/qti-aic/tools/qaic-version-util

echo
echo "Done. Please reboot for the user to be added into the groups."
