#!/bin/bash
#Usage: WORKSPACE=/local/mnt/workspace ./ck_init.sh
WORKSPACE=${WORKSPACE:-$HOME/MLC2.0}

echo -n "\
export CK_PYTHON=${CK_PYTHON:-$(which python3)}
export CK_WORKSPACE=$WORKSPACE
export CK_TOOLS=$WORKSPACE/$USER/CK-TOOLS
export CK_REPOS=$WORKSPACE/$USER/CK-REPOS
export CK_EXPERIMENT_REPO=mlperf_v2.0.$(hostname).$USER
export CK_EXPERIMENT_DIR=$CK_REPOS/$CK_EXPERIMENT_REPO/experiment
export PATH=$HOME/.local/bin:$PATH" >> $HOME/.bashrc
source $HOME/.bashrc

sudo mkdir -p $CK_WORKSPACE/$USER && sudo chown $USER:qaic $CK_WORKSPACE/$USER

$CK_PYTHON -m pip install --ignore-installed pip setuptools testresources ck==2.6.1 --user --upgrade
ck pull repo --url=https://github.com/krai/ck-qaic

ck add repo:$CK_EXPERIMENT_REPO --quiet
ck add $CK_EXPERIMENT_REPO:experiment:dummy --common_func
ck rm  $CK_EXPERIMENT_REPO:experiment:dummy --force
chgrp -R qaic $CK_EXPERIMENT_DIR
chmod -R g+ws $CK_EXPERIMENT_DIR
setfacl -R -d -m group:qaic:rwx $CK_EXPERIMENT_DIR
