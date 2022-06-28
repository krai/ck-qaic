#!/bin/bash

# Update the Repo URLs. (CentOS 8 has reached End of Life.)
cd /etc/yum.repos.d/
sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
cd

# Install system-level packages via 'yum'.
yum upgrade -y
yum install -y make which patch vim git wget zip unzip openssl-devel bzip2-devel libffi-devel tmux epel-release
yum install -y htop
yum install -y dnf
yum clean all
# Install system-level packages via 'dnf'.
dnf install -y libarchive cmake
dnf install -y scl-utils
dnf install -y gcc-toolset-11-gcc-c++

# Install Python >= 3.7 from source.
export PYTHON_VERSION=3.9.13
cd /usr/src \
&& wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz \
&& tar xzf Python-${PYTHON_VERSION}.tgz \
&& rm -f Python-${PYTHON_VERSION}.tgz \
&& cd /usr/src/Python-${PYTHON_VERSION} \
&& ./configure --enable-optimizations && make -j8 altinstall \
&& rm -rf /usr/src/Python-${PYTHON_VERSION}*

# Create group 'qaic'.
groupadd -f qaic
# Create group 'krai'.
groupadd -f krai
# Create user 'krai'.
_BASE_DIR=${BASE_DIR:-"/data"}
useradd -m -g krai -s /bin/bash -b ${_BASE_DIR} krai
# Add user 'krai' to some groups.
usermod -aG qaic,root,wheel krai
# Do not ask user 'krai' for 'sudo' password.
echo "krai ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Fix permissions on the 'sudo' command.
chown root:root /usr/bin/sudo && chmod 4755 /usr/bin/sudo

# Set the London timezone (for power measurements).
rm /etc/localtime -f
ln -s /usr/share/zoneinfo/Europe/London /etc/localtime
date
