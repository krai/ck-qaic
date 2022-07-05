#!/bin/bash

function exit_if_error() {
  if [ "${?}" != "0" ]; then
    echo ""
    echo "ERROR: $1"
    exit 1
  fi
}

_DEVICE_OS=${DEVICE_OS:-centos}
# _BENCHMARKS = ${BENCHMARKS:-("image_classification" "object_detection" "language_processing")}
_BENCHMARKS=${BENCHMARKS:-("image_classification" "object_detection" "language_processing")}
_DEVICE_DATASETS_DIR=${DEVICE_DATASETS_DIR:-"/data"}
_CK_VER=${CK_VER:-2.6.1}

echo " Setting Parameters:"
echo "- BENCHMARKS=${_BENCHMARKS}"
echo "- DEVICE_DATASETS_DIR=${_DEVICE_DATASETS_DIR}"
echo "- CK_VER =${_CK_VER}"
echo

# Set up environment
if [[ -z $(grep "# CK-QAIC." ~/.bashrc) ]]; then
  echo "Adding CK-QAIC environment to '~/.bashrc'."
  echo -n "\

# CK-QAIC.
export CK_PYTHON=$(which python3.9)
export PATH=$HOME/.local/bin:$PATH" >> $HOME/.bashrc
  
  # Centos OS Dependency
  if [[ "${_DEVICE_OS}" == centos ]]; then
    echo -n "source scl_source enable gcc-toolset-11" >> $HOME/.bashrc
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
$CK_PYTHON -m pip install transformers==2.4.0 --user

# Install CK.
$CK_PYTHON -m pip install ck==${_CK_VER}
ck set kernel var.package_quiet_install=yes
ck pull repo --url=https://github.com/krai/ck-qaic

# Init CK environment.
ck detect platform.os --platform_init_uoa=aedk
ck detect soft:compiler.python --full_path=$(which $CK_PYTHON)
ck detect soft:compiler.gcc --full_path=$(which gcc)
ck detect soft:tool.cmake --full_path=$(which cmake)

# Install explicit Python dependencies.
echo "1.2x" | ck install package --tags=python-package,numpy
ck install package --tags=python-package,absl
ck install package --tags=python-package,cython
ck install package --tags=python-package,opencv-python-headless

# Install LoadGen.
ck install package --tags=mlperf,inference,source
ck install package --tags=mlperf,loadgen,static
ck install package --tags=mlperf,power,source

# Install Benchmark dependencies.
BENCHMARKS=${_BENCHMARKS} DEVICE_DATASETS_DIR=${_DEVICE_DATASETS_DIR} ./3.install_benchmark.sh
