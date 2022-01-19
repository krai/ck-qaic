#!/bin/bash

# Set up environment.
echo 'export CK_PYTHON=$(which python3.8)' >> $HOME/.bashrc
echo 'export PATH=$HOME/.local/bin:$PATH' >> $HOME/.bashrc
source $HOME/.bashrc

# Set up GCC >= 9.
echo "source scl_source enable gcc-toolset-11" >> ~/.bashrc
source ~/.bashrc

# Set up Git.
export GIT_USER="krai"
export GIT_EMAIL="info@krai.ai"
git config --global user.name ${GIT_USER} && git config --global user.email ${GIT_EMAIL}
curl https://sh.rustup.rs -sSf | sh

# Install Python dependencies.
$CK_PYTHON -m pip install --ignore-installed pip setuptools testresources wheel --user --upgrade
$CK_PYTHON -m pip install h5py
$CK_PYTHON -m pip install tensorflow-aarch64 -f https://tf.kmtea.eu/whl/stable.html
$CK_PYTHON -m pip install ck==2.6.1

# Set up CK.
ck version
ck set kernel var.package_quiet_install=yes
ck pull repo --url=https://github.com/krai/ck-qaic
ck detect platform.os --platform_init_uoa=aedk
ck detect soft:compiler.python --full_path=$(which python3.8)
ck detect soft:compiler.gcc --full_path=$(which gcc)

# Install CMake from source. (FIXME: install using yum?)
ck install package --tags=tool,cmake,from.source

# Install explicit Python dependencies.
ck install package --tags=python-package,numpy
ck install package --tags=python-package,absl
ck install package --tags=python-package,cython
ck install package --tags=python-package,opencv-python-headless

# TODO: Install LoadGen.
