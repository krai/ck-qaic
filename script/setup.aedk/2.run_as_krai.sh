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

# Add user 'krai' to required groups.
if [[ "${_DEVICE_OS}" == "centos" ]]; then
  _DEVICE_GROUPS="root,qaic,wheel"
elif [[ "${_DEVICE_OS}" == "ubuntu" ]]; then
  _DEVICE_GROUPS="sudo,qaic"
fi
echo "Adding user '${_DEVICE_USER}' to groups '${_DEVICE_GROUPS}' ..."
sudo usermod -aG ${_DEVICE_GROUPS} ${_DEVICE_USER}

# Set up environment.
if [[ -z $(grep "# CK-QAIC." ~/.bashrc) ]]; then
  echo "Adding CK-QAIC environment to '~/.bashrc' ..."
  echo -n "\
# CK-QAIC.
export CK_PYTHON=$(which python${_PYTHON_VERSION_MAJOR}.${_PYTHON_VERSION_MINOR})
export LD_LIBRARY_PATH=/opt/qti-aic/dev/lib/aarch64:$LD_LIBRARY_PATH
export PATH=$HOME/.local/bin:/opt/qti-aic/tools:$PATH" >> ~/.bashrc
  # CentOS-specific dependency.
  #if [[ "${_DEVICE_OS}" == centos ]]; then
  #  echo "source scl_source enable gcc-toolset-11" >> ~/.bashrc
  #fi
else
  echo "CK-QAIC environment has already been added to '~/.bashrc'."
fi
source ~/.bashrc

# Configure Git.
export GIT_USER="krai"
export GIT_EMAIL="info@krai.ai"
git config --global user.name ${GIT_USER} && git config --global user.email ${GIT_EMAIL}

# Install the Rust compiler.
curl https://sh.rustup.rs -sSf > /tmp/install_rust.sh && sh /tmp/install_rust.sh -y

# Install implicit Python dependencies.
${_CK_PYTHON} -m pip install pip setuptools testresources wheel h5py --user --upgrade --ignore-installed
${_CK_PYTHON} -m pip install tensorflow-aarch64 -f https://tf.kmtea.eu/whl/stable.html --user
${_CK_PYTHON} -m pip install transformers --user
# Install CK.
${_CK_PYTHON} -m pip install ck==${_CK_VERSION}

echo
echo "Done."
