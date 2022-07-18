#!/bin/bash

# Example usage: WORKSPACE_DIR=/local/mnt/workspace PYTHON_VER=3.8 bash setup_ck.sh

_WORKSPACE_DIR=${WORKSPACE_DIR:-/local/mnt/workspace}
_MLPERF_VER=${MLPERF_VER:-2.1}
_PYTHON_VER=${PYTHON_VER:-3.8}
_CK_VER=${CK_VER:-2.6.1}

export CK_PYTHON=${CK_PYTHON:-$(which python${_PYTHON_VER})}
export CK_WORKSPACE=${_WORKSPACE_DIR}
export CK_TOOLS=${_WORKSPACE_DIR}/$USER/CK-TOOLS
export CK_REPOS=${_WORKSPACE_DIR}/$USER/CK-REPOS
export CK_EXPERIMENT_REPO=mlperf_v${_MLPERF_VER}.'$(hostname)'.$USER
export CK_EXPERIMENT_DIR=$CK_REPOS/$CK_EXPERIMENT_REPO/experiment
export PATH=$HOME/.local/bin:$PATH

# Install CK and essential dependencies.
$CK_PYTHON -m pip install --ignore-installed --user --upgrade \
  pip setuptools testresources ck==${_CK_VER}

# Pull CK-QAIC repo and its dependencies.
ck pull repo --url=https://github.com/krai/ck-qaic

# Add CK-QAIC environment variables to '~/.bashrc' with unexpanded hostname.
if [[ -z $(grep "# CK-QAIC." ~/.bashrc) ]]; then
  echo -n "\
# CK-QAIC.
export CK_PYTHON=${CK_PYTHON}
export CK_WORKSPACE=${_WORKSPACE_DIR}
export CK_TOOLS=$CK_TOOLS
export CK_REPOS=$CK_REPOS
export CK_EXPERIMENT_REPO=$CK_EXPERIMENT_REPO
export CK_EXPERIMENT_DIR=$CK_EXPERIMENT_DIR
export PATH=$PATH" >> $HOME/.bashrc
  source $HOME/.bashrc
  sudo mkdir -p $CK_WORKSPACE/$USER && sudo chown $USER:qaic $CK_WORKSPACE/$USER
else
  echo "CK-QAIC environment has already been added to '~/.bashrc'."
fi

# Set up CK-QAIC experiment repository with expanded hostname.
export CK_EXPERIMENT_REPO=$(eval echo ${CK_EXPERIMENT_REPO})
export CK_EXPERIMENT_DIR=$CK_REPOS/$CK_EXPERIMENT_REPO/experiment
if [[ -z $(find $CK_REPOS -name $CK_EXPERIMENT_REPO) ]]; then
  # Repo with no experiments.
  ck add repo:$CK_EXPERIMENT_REPO --quiet
  ck add $CK_EXPERIMENT_REPO:experiment:dummy --common_func
  ck rm  $CK_EXPERIMENT_REPO:experiment:dummy --force
  # Access permissions.
  chgrp -R qaic $CK_EXPERIMENT_DIR
  chmod -R g+ws $CK_EXPERIMENT_DIR
  setfacl -R -d -m group:qaic:rwx $CK_EXPERIMENT_DIR
else
  echo "CK-QAIC repository '$CK_EXPERIMENT_REPO' has already been created."
fi

echo
echo "Done (setting up CK environment)."
echo
