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
#FROM qran-centos7:1.6.80
# NB: Setting FROM from ARGs only works starting with Docker 1.17.
# (CentOS 7 comes with 1.13.)
ARG BASE_OS
ARG CK_QAIC_CHECKOUT
FROM krai/ck.common:${BASE_OS}_latest AS preamble

# Use the Bash shell.
SHELL ["/bin/bash", "-c"]

# Allow stepping into the Bash shell interactively.
ENTRYPOINT ["/bin/bash", "-c"]

###############################################################################
# BUILDER STAGE
#
# In this stage, only perform steps that write into CK, CK_TOOLS, CK_REPOS,
# which can be simply copied into the final image.
#
###############################################################################
FROM preamble AS builder
ARG CK_QAIC_CHECKOUT

# Pull CK repositories.
RUN cd $(ck find repo:ck-qaic) && git checkout ${CK_QAIC_CHECKOUT} && ck pull all

# Install implicit Python dependencies.
RUN source /home/krai/.bashrc \
 && ${CK_PYTHON} -m pip install --user pybind11 protobuf==3.19.4 onnx-simplifier==0.3.7

# Set platform scripts (ensuring that ECC is on).
RUN ck detect platform.os --platform_init_uoa=qaic

#-----------------------------------------------------------------------------#
# Step 1. Install explicit Python dependencies.
#-----------------------------------------------------------------------------#
RUN ck install package --tags=python-package,onnx,for.qaic --quiet \
 && ck install package --tags=lib,python-package,torch --force_version=1.8.1 --quiet \
 && ck install package --tags=tool,coco --quiet

#-----------------------------------------------------------------------------#
# Step 2. INTENTIONALLY LEFT BLANK.
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
# Step 3. Download the dataset.
#-----------------------------------------------------------------------------#
RUN ck install package --tags=dataset,coco.2017,val --quiet

#-----------------------------------------------------------------------------#
# The steps above are common for SSD-ResNet34 and SSD-MobileNet-v1.
# The steps below are SSD-MobileNet-v1 specific.
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
# Step 4. Preprocess the dataset for quantized SSD-MobileNet.
#-----------------------------------------------------------------------------#
RUN ck install package --tags=dataset,for.ssd_mobilenet.onnx.preprocessed,calibration,mlperf --quiet
RUN ck install package --dep_add_tags.lib-python-cv2=opencv-python-headless \
--tags=dataset,object-detection,for.ssd_mobilenet.onnx.preprocessed.quantized,using-opencv,full,validation

#-----------------------------------------------------------------------------#
# Step 5. Prepare the SSD-MobileNet workload.
#-----------------------------------------------------------------------------#
# Remove NMS.
RUN ck install package --tags=model,pytorch,mlperf,ssd-mobilenet,for.qaic --quiet

#-----------------------------------------------------------------------------#
# Step 6. Clean up.
#-----------------------------------------------------------------------------#
RUN rm -rf $(ck locate env --tags=dataset,coco.2017,original,train)/*  \
  $(ck locate env --tags=dataset,coco.2017,original,val)/val2017/* && \
  touch $(ck locate env --tags=dataset,coco.2017,original,val)/val2017/000000000139.jpg; 

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
COPY --from=builder /home/krai/.local   /home/krai/.local
COPY --from=builder /home/krai/.bashrc  /home/krai/.bashrc
