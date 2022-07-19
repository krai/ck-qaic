#!/bin/bash

_DEVICE_OS=${DEVICE_OS:-centos}
_PYTHON_VERSION=${PYTHON_VERSION:-3.9.13}
_DEVICE_USER=${DEVICE_USER:-krai}
_CK_VER=${CK_VER:-2.6.1}
_INSTALL_PYTHON_DEPENDENCY=${INSTALL_PYTHON_DEPENDENCY:-"yes"}
_INSTALL_LOADGEN=${INSTALL_LOADGEN:-"yes"}

. run_common.sh

echo "Running '$0'"
print_variables "${!_@}"

# Add user 'krai' to some groups
if [[ "${_DEVICE_OS}" == "centos" ]]; then
  echo "set for centos"
  sudo usermod -aG qaic,root,wheel ${_DEVICE_USER}
elif [[ "${_DEVICE_OS}" == "ubuntu" ]]; then
  echo "set for ubuntu"
  sudo usermod -aG qaic,sudo ${_DEVICE_USER}
fi

# Set up environment
if [[ -z $(grep "# CK-QAIC." ~/.bashrc) ]]; then
  echo "Adding CK-QAIC environment to '~/.bashrc'."
  _PYTHON_VERSION_ARR=($(echo ${_PYTHON_VERSION} | tr "." " "))
  _PYTHON_MAJOR=${_PYTHON_VERSION_ARR[0]}
  _PYTHON_MINOR=${_PYTHON_VERSION_ARR[1]}
  _PYTHON_BATCH=${_PYTHON_VERSION_ARR[2]}
  echo -n "\
# CK-QAIC.
export CK_PYTHON=$(which python${_PYTHON_MAJOR}.${_PYTHON_MINOR})
export PATH=$HOME/.local/bin:$PATH" >> $HOME/.bashrc

  # Centos OS Dependency
  if [[ "${_DEVICE_OS}" == centos ]]; then
    echo -n "\
source scl_source enable gcc-toolset-11" >> $HOME/.bashrc
  fi

  source $HOME/.bashrc
else
  echo "CK-QAIC environment has already been added to '~/.bashrc'."
fi

# Configure Git.
export GIT_USER="krai"
export GIT_EMAIL="info@krai.ai"
git config --global user.name ${GIT_USER} && git config --global user.email ${GIT_EMAIL}

# Install the Rust compiler.
curl https://sh.rustup.rs -sSf > /tmp/install_rust.sh && sh /tmp/install_rust.sh -y

# Install implicit Python dependencies.
$CK_PYTHON -m pip install pip setuptools testresources wheel h5py --user --upgrade --ignore-installed
$CK_PYTHON -m pip install tensorflow-aarch64 -f https://tf.kmtea.eu/whl/stable.html --user
$CK_PYTHON -m pip install transformers --user

# Install CK.
$CK_PYTHON -m pip install ck==${_CK_VER}
ck pull repo --url=https://github.com/krai/ck-qaic

# Init CK environment.
ck detect platform.os --platform_init_uoa=aedk
ck detect soft:compiler.python --full_path=$(which $CK_PYTHON)
ck detect soft:compiler.gcc --full_path=$(which gcc)
ck detect soft:tool.cmake --full_path=$(which cmake)

# Install explicit Python dependencies.
if [[ "${_INSTALL_PYTHON_DEPENDENCY}" == "yes" ]]; then
  echo "Installing explicit Python dependencies."
  echo "1.2x" | ck install package --tags=python-package,numpy
  ck install package --tags=python-package,absl
  ck install package --tags=python-package,cython
  ck install package --tags=python-package,opencv-python-headless
else
  echo "Passing explicit Python dependencies installation."
fi

# Install LoadGen.
if [[ "${_INSTALL_LOADGEN}" == "yes" ]]; then
  echo "Installing loadgen."
  ck install package --tags=mlperf,inference,source
  ck install package --tags=mlperf,loadgen,static
  ck install package --tags=mlperf,power,source
else
  echo "Passing loadgen installation."
fi