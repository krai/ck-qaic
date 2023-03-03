#!/bin/bash

_INSTALL_SYSTEM_PACKAGES=${INSTALL_SYSTEM_PACKAGES:-yes}
_INSTALL_GITHUB_CLI=${INSTALL_GITHUB_CLI:-yes}

echo "Running '$0' ..."
print_variables "${!_@}"
echo "Press Ctrl-C to break ..."
sleep 5

# Install system packages using apt.
echo "Installing system packages ..."
if [[ "${_INSTALL_SYSTEM_PACKAGES}" == "yes" ]]; then
  apt update -y
  apt upgrade -y
  apt install -y \
    git wget patch vim \
    libbz2-dev lzma libffi-dev \
    python3-dev python3-pip \
    lm-sensors ipmitool \
    ca-certificates curl gnupg lsb-release \
    acl \
    bc rsync cmake \
    htop tmux tree
  apt clean all
  exit_if_error "apt install failed!"
else
  echo "- skipping ..."
fi

# Install GitHub's Command Line Interface (CLI).
echo "Installing GitHub CLI ..."
if [[ "${_INSTALL_GITHUB_CLI}" == "yes" ]]; then
  type -p curl >/dev/null || apt install curl -y
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
  	&& chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
  	&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
  	&& apt update \
  	&& apt install gh -y
fi
