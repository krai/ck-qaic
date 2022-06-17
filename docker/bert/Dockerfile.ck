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
#
# In this stage, only perform steps that benefit the final image.
#
###############################################################################
FROM krai/ck.common.centos7 AS preamble
ARG CK_QAIC_CHECKOUT

###############################################################################
# BUILDER STAGE
#
# In this stage, only perform steps that write into CK, CK_TOOLS, CK_REPOS,
# which can be simply copied into the final image.
#
###############################################################################
FROM preamble AS builder
ARG CK_QAIC_CHECKOUT
ARG GCC_MAJOR_VERSION

# Update CK repositories.
RUN cd $(ck find repo:ck-qaic) && git checkout ${CK_QAIC_CHECKOUT} \
 && ck pull all

#-----------------------------------------------------------------------------#
# Step 1. Install explicit Python dependencies (and their dependencies).
#-----------------------------------------------------------------------------#

# Install Rust compiler >= 1.32.0 to build tokenizers==0.0.11 for Python >= 3.10.
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs > /tmp/install_rust.sh \
 && sh /tmp/install_rust.sh -y \
 && source /home/krai/.bashrc \
 && scl enable devtoolset-${GCC_MAJOR_VERSION} \
    "ck install package --tags=lib,python-package,transformers --force_version=2.4.0"

# Install Protobuf compiler/headers and CMake >= 3.1 to build onnx.
RUN sudo yum install -y protobuf-c-compiler protobuf-devel \
 && sudo yum install -y http://repo.okay.com.mx/centos/7/x86_64/release/okay-release-1-1.noarch.rpm \
 && sudo yum install -y cmake3 && sudo ln -s /usr/bin/cmake3 /usr/bin/cmake
RUN source /home/krai/.bashrc && ${CK_PYTHON} -m pip install pybind11==2.2.4
RUN scl enable devtoolset-${GCC_MAJOR_VERSION} \
    "pybind_DIR=/home/krai/.local/lib/python3.10/site-packages/pybind11/share/cmake/pybind11 CMAKE_PREFIX_PATH=/home/krai/.local/lib/python3.10/site-packages/pybind11 ck install package --tags=python-package,onnx --force_version=1.8.0 --quiet"

RUN ck install package --tags=lib,python-package,pytorch --force_version=1.8.1 --quiet \
 && ck install package --tags=lib,python-package,tensorflow --force_version=2.9.1 --quiet

#-----------------------------------------------------------------------------#
# Step 2. Install implicit Python dependencies.
#-----------------------------------------------------------------------------#
RUN source /home/krai/.bashrc \
 && ${CK_PYTHON} -m pip install --user onnx-simplifier \
 && ${CK_PYTHON} -m pip install --user tokenization \
 && ${CK_PYTHON} -m pip install --user nvidia-pyindex \
 && ${CK_PYTHON} -m pip install --user onnx-graphsurgeon==0.3.11

#-----------------------------------------------------------------------------#
# Step 3. Download the SQuAD v1.1 dataset.
#-----------------------------------------------------------------------------#
RUN ck install package --tags=dataset,squad,raw,width.384 \
 && ck install package --tags=dataset,calibration,squad,pickle,width.384

#-----------------------------------------------------------------------------#
# Step 4. Prepare the BERT workload.
#-----------------------------------------------------------------------------#
RUN ck install package --tags=model,mlperf,qaic,bert-packed

###############################################################################
# FINAL STAGE
#
# In this stage, simply copy CK, CK_TOOLS, CK_REPOS to the final image.
#
###############################################################################
FROM preamble AS final

COPY --from=builder /home/krai/CK       /home/krai/CK
COPY --from=builder /home/krai/CK_REPOS /home/krai/CK_REPOS
COPY --from=builder /home/krai/CK_TOOLS /home/krai/CK_TOOLS
COPY --from=builder /home/krai/.bashrc  /home/krai/.bashrc
COPY --from=builder /home/krai/.local   /home/krai/.local
