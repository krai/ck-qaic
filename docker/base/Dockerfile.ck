#
# Copyright (c) 2021-2022 Krai Ltd.
#
# SPDX-License-Identifier: BSD-3-Clause.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
# this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its contributors
# may be used to endorse or promote products derived from this software without
# specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#

###############################################################################
# PREABMLE STAGE
###############################################################################
ARG DOCKER_OS
ARG BASE_IMAGE=krai/base:${DOCKER_OS}_latest
FROM $BASE_IMAGE AS preamble

ARG GCC_MAJOR_VER
ARG PYTHON_VER
ARG CK_VER

ARG GROUP_ID
ARG USER_ID

# Create a non-root user with a fixed group id and a fixed user id.
RUN groupadd -g ${GROUP_ID} kraig
RUN useradd -u ${USER_ID} -g kraig --create-home --shell /bin/bash krai
# Allow this user to execute commands with sudo.
RUN echo "krai ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER krai:kraig
WORKDIR /home/krai

ENV CK_ROOT=/home/krai/CK \
    CK_REPOS=/home/krai/CK_REPOS \
    CK_TOOLS=/home/krai/CK_TOOLS \
    PATH=${CK_ROOT}/bin:/home/krai/.local/bin:${PATH} \
    LD_LIBRARY_PATH=/usr/local/lib:${LD_LIBRARY_PATH} \
    LIBRARY_PATH=/usr/local/lib:${LIBRARY_PATH} \
    CK_CC=gcc \
    GIT_USER="krai" \
    GIT_EMAIL="info@krai.ai" \
    LANG=C.UTF-8

RUN git config --global user.name ${GIT_USER} && git config --global user.email ${GIT_EMAIL} \
 && git clone --branch V${CK_VER} https://github.com/ctuning/ck.git ${CK_ROOT} \
 && mkdir -p ${CK_REPOS} ${CK_TOOLS} .local

###############################################################################
### BUILDER STAGE
###############################################################################
FROM preamble AS builder

ARG CK_QAIC_CHECKOUT

ARG GCC_MAJOR_VER

ARG PYTHON_VER
ARG PYTHON_MAJOR_VER
ARG PYTHON_MINOR_VER
ARG PYTHON_PATCH_VER

ENV CK_PYTHON=python${PYTHON_MAJOR_VER}.${PYTHON_MINOR_VER}

# Work out the subversions of Python and place them into the Bash resource file.
RUN /bin/bash -l -c  \
 'echo "export PYTHON_MAJOR_VER=${PYTHON_MAJOR_VER}" >> /home/krai/.bashrc;\
  echo "export PYTHON_MINOR_VER=${PYTHON_MINOR_VER}" >> /home/krai/.bashrc;\
  echo "export PYTHON_PATCH_VER=${PYTHON_PATCH_VER}" >> /home/krai/.bashrc' \
 && source /home/krai/.bashrc \
 && /bin/bash -l -c \
 'echo "export CK_PYTHON=${CK_PYTHON}" >> /home/krai/.bashrc' \

# Install Collective Knowledge (CK).
RUN source /home/krai/.bashrc \
 && cd ${CK_ROOT} && ${CK_PYTHON} ${CK_ROOT}/setup.py install --user \
 && ${CK_PYTHON} -c "import ck.kernel as ck; print ('Collective Knowledge v%s' % ck.__version__)" \
 && chmod -R g+rx /home/krai/.local \
 && ${CK_PYTHON} -m pip install pyyaml

# Explicitly create a CK experiment entry, a folder that will be mounted
# (with '--volume=<folder_for_results>:/home/krai/CK_REPOS/local/experiment').
# as a shared volume between the host and the container, and make it group-writable.
# For consistency, use the "canonical" uid from ck-analytics:module:experiment.
RUN ck create_entry --data_uoa=experiment --data_uid=bc0409fb61f0aa82 --path=${CK_REPOS}/local\
 && chmod -R g+ws ${CK_REPOS}/local/experiment

# Pull CK repositories (including ck-mlperf and ck-env).
RUN ck pull repo --url=https://github.com/krai/ck-qaic
RUN cd $(ck find repo:ck-qaic) && git checkout ${CK_QAIC_CHECKOUT}

# Detect Python interpreter, install the latest package installer (pip) and implicit dependencies.
RUN source /home/krai/.bashrc \
 && ck detect soft:compiler.python --full_path=$(which ${CK_PYTHON}) \
 && ${CK_PYTHON} -m pip install --user --ignore-installed pip setuptools \
 && ${CK_PYTHON} -m pip install --user wheel pyyaml testresources

# Detect C/C++ compiler (gcc).
#RUN echo "0" | ck detect soft:compiler.gcc --full_path=$(scl enable devtoolset-${GCC_MAJOR_VER} 'which ${CK_CC}')
RUN ck detect soft:compiler.gcc --full_path=$(which ${CK_CC})

# Install CMake.
RUN ck install package --tags=tool,cmake,downloaded --quiet

# Install explicit dependencies.
RUN ck install package --tags=python-package,cython \
 && ck install package --tags=python-package,absl \
 && ck install package --tags=python-package,matplotlib --quiet \
 && ck install package --tags=python-package,opencv-python-headless \
 && echo "latest" | ck install package --tags=python-package,numpy

RUN ck install package --tags=mlperf,inference,source,r2.0 --quiet \
 && ck install package --tags=mlperf,loadgen,static \
 && ck install package --tags=mlperf,power,source --quiet

###############################################################################
### FINAL STAGE
###############################################################################
FROM preamble AS final

COPY --from=builder /home/krai/CK       /home/krai/CK
COPY --from=builder /home/krai/CK_REPOS /home/krai/CK_REPOS
COPY --from=builder /home/krai/CK_TOOLS /home/krai/CK_TOOLS
COPY --from=builder /home/krai/.local   /home/krai/.local
COPY --from=builder /home/krai/.bashrc  /home/krai/.bashrc

CMD ["ck version"]
