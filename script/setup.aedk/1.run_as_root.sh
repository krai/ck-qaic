#!/bin/bash

# Install system-level packages via 'yum'.
yum upgrade -y
yum install -y make which patch vim git wget zip unzip openssl-devel bzip2-devel libffi-devel
yum install -y epel-release htop tmux
yum install -y dnf
yum clean all
# Install system-level packages via 'dnf'.
dnf install -y libarchive cmake
dnf install -y scl-utils
dnf install -y gcc-toolset-11-gcc-c++

# Install Python >= 3.7 from source.
export PYTHON_VERSION=3.8.12
cd /usr/src \
&& wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz \
&& tar xzf Python-${PYTHON_VERSION}.tgz \
&& rm -f Python-${PYTHON_VERSION}.tgz \
&& cd /usr/src/Python-${PYTHON_VERSION} \
&& ./configure --enable-optimizations && make -j8 altinstall \
&& rm -rf /usr/src/Python-${PYTHON_VERSION}*

# Create group 'qaic' if it does not exist.
groupadd -f qaic
# Add user 'krai' to some groups.
usermod -aG qaic,root,wheel krai
# Do not ask user 'krai' for 'sudo' password.
echo "krai ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Fix permissions on the 'sudo' command.
chown root:root /usr/bin/sudo && chmod 4755 /usr/bin/sudo
