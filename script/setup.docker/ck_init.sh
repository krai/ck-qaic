#!/bin/bash

# Usage: WORKSPACE_DIR=/local/mnt/workspace ./ck_init.sh

_WORKSPACE_DIR=${WORKSPACE_DIR:-/local/mnt/workspace}

export CK_PYTHON=${CK_PYTHON:-$(which python3.8)}
export CK_WORKSPACE=${_WORKSPACE_DIR}
export CK_TOOLS=${_WORKSPACE_DIR}/$USER/CK-TOOLS
export CK_REPOS=${_WORKSPACE_DIR}/$USER/CK-REPOS
export CK_EXPERIMENT_REPO=mlperf_v2.0.$(hostname).$USER
export CK_EXPERIMENT_DIR=$CK_REPOS/$CK_EXPERIMENT_REPO/experiment
export PATH=$HOME/.local/bin:$PATH

echo -n "\
export CK_PYTHON=${CK_PYTHON}
export CK_WORKSPACE=${_WORKSPACE_DIR}
export CK_TOOLS=$CK_TOOLS
export CK_REPOS=$CK_REPOS
export CK_EXPERIMENT_REPO=$CK_EXPERIMENT_REPO
export CK_EXPERIMENT_DIR=$CK_EXPERIMENT_DIR
export PATH=$PATH" >> $HOME/.bashrc

source ~/.bashrc

sudo mkdir -p $CK_WORKSPACE/$USER && sudo chown $USER:qaic $CK_WORKSPACE/$USER

$CK_PYTHON -m pip install --ignore-installed pip setuptools testresources ck==2.6.1 --user --upgrade
ck pull repo --url=https://github.com/krai/ck-qaic

ck add repo:$CK_EXPERIMENT_REPO --quiet
ck add $CK_EXPERIMENT_REPO:experiment:dummy --common_func
ck rm  $CK_EXPERIMENT_REPO:experiment:dummy --force
chgrp -R qaic $CK_EXPERIMENT_DIR
chmod -R g+ws $CK_EXPERIMENT_DIR
setfacl -R -d -m group:qaic:rwx $CK_EXPERIMENT_DIR
