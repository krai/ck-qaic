#!/bin/bash

_DEVICE_OS=${DEVICE_OS:-ubuntu}
_DEVICE_OS_OVERRIDE=${DEVICE_OS_OVERRIDE:-no}
_DEVICE_USER=${DEVICE_USER:-krai}

_INSTALL_LOADGEN=${INSTALL_LOADGEN:-yes}
_INSTALL_PYTHON_DEPS=${INSTALL_PYTHON_DEPS:-yes}

_CK_VERSION=${CK_VERSION:-${CK_VER:-2.6.1}}

_PYTHON_VERSION=${PYTHON_VERSION:-${PYTHON_VER:-3.9.14}}
_PYTHON_VERSION_ARRAY=($(echo ${_PYTHON_VERSION} | tr "." " "))
_PYTHON_VERSION_MAJOR=${_PYTHON_VERSION_ARRAY[0]}
_PYTHON_VERSION_MINOR=${_PYTHON_VERSION_ARRAY[1]}
_PYTHON_VERSION_PATCH=${_PYTHON_VERSION_ARRAY[2]}
_CK_PYTHON=${CK_PYTHON:-"python${_PYTHON_VERSION_MAJOR}.${_PYTHON_VERSION_MINOR}"}

_MLPERF_VERSION=${MLPERF_VERSION:-${MLPERF_VER:-2.1}}
_MLPERF_INFERENCE_VERSION=${MLPERF_INFERENCE_VERSION:-${_MLPERF_VERSION}}
_MLPERF_POWER_VERSION=${MLPERF_POWER_VERSION:-${_MLPERF_VERSION}}

. common.sh

# Determine device OS.
get_os ${_DEVICE_OS} ${_DEVICE_OS_OVERRIDE}

# Print environment variables.
echo "Running '$0' ..."
print_variables "${!_@}"
echo
echo "Press Ctrl-C to break ..."
sleep 10

ck version
ck pull repo --url=https://github.com/krai/ck-qaic

# Init CK environment.
ck detect platform.os --platform_init_uoa=aedk
ck detect soft:compiler.python --full_path=$(which ${_CK_PYTHON})
ck detect soft:compiler.gcc --full_path=$(which gcc)
ck detect soft:tool.cmake --full_path=$(which cmake)

# Install explicit Python dependencies.
echo "Installing explicit Python dependencies ..."
if [[ "${_INSTALL_PYTHON_DEPS}" == "yes" ]]; then
  echo "1.2x" | ck install package --tags=python-package,numpy
  ck install package --tags=python-package,absl
  ck install package --tags=python-package,cython
  ck install package --tags=python-package,opencv-python-headless
else
  echo "- skipping ..."
fi

# Install LoadGen.
echo "Installing LoadGen ..."
if [[ "${_INSTALL_LOADGEN}" == "yes" ]]; then
  ck install package --tags=mlperf,inference,source,r${_MLPERF_INFERENCE_VERSION}
  ck install package --tags=mlperf,power,source,r${_MLPERF_POWER_VERSION}
  ck install package --tags=mlperf,loadgen,static
  ck install package --tags=qaic,master
else
  echo "- skipping ..."
fi

echo
echo "Done."
