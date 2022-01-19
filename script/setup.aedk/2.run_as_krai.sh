#!/bin/bash

# Set up environment.
echo 'export CK_PYTHON=$(which python3.8)'     >> $HOME/.bashrc
echo 'export PATH=$HOME/.local/bin:$PATH'      >> $HOME/.bashrc
echo "source scl_source enable gcc-toolset-11" >> $HOME/.bashrc
source $HOME/.bashrc

# Set up Git.
export GIT_USER="krai"
export GIT_EMAIL="info@krai.ai"
git config --global user.name ${GIT_USER} && git config --global user.email ${GIT_EMAIL}
curl https://sh.rustup.rs -sSf | sh

# Install implicit Python dependencies.
$CK_PYTHON -m pip install pip setuptools testresources wheel h5py --user --upgrade --ignore-installed
$CK_PYTHON -m pip install tensorflow-aarch64 -f https://tf.kmtea.eu/whl/stable.html

# Set up CK.
$CK_PYTHON -m pip install ck==2.6.1
ck set kernel var.package_quiet_install=yes
ck pull repo --url=https://github.com/krai/ck-qaic

# Init CK environment.
ck detect platform.os --platform_init_uoa=aedk
ck detect soft:compiler.python --full_path=$(which python3.8)
ck detect soft:compiler.gcc --full_path=$(which gcc)
ck detect soft:tool.cmake --full_path=$(which cmake)

# Install explicit Python dependencies.
ck install package --tags=python-package,numpy
ck install package --tags=python-package,absl
ck install package --tags=python-package,cython
ck install package --tags=python-package,opencv-python-headless

# TODO: Install LoadGen.
