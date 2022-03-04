#!/bin/bash

_SDK_VER=${SDK_VER:-1.6.80}
_SDK_DIR=${SDK_DIR:-/local/mnt/workspace/sdks}
_APPS_SDK=${APPS_SDK:-"${_SDK_DIR}/qaic-apps-${_SDK_VER}.zip"}
if [[ ! -f "${_APPS_SDK}" ]]; then
  echo "ERROR: File '${_APPS_SDK}' does not exist!"
  exit 1
fi
echo "Using Apps SDK: ${_APPS_SDK}"

unzip -o ${_APPS_SDK} -d "$(dirname $_APPS_SDK)"

cd ${_APPS_SDK::-4}
echo "yes" | sudo ./uninstall.sh
sudo ./install.sh

