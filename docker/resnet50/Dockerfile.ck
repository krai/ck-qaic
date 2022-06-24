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
# NB: Feeding FROM from ARGs only works starting with Docker 1.17. 
# (CentOS 7 comes with 1.13.)
ARG IMAGENET=full
ARG CK_QAIC_CHECKOUT
ARG DOCKER_OS
FROM krai/ck.common:${DOCKER_OS}_latest AS preamble

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
# Use the full (50000 images) or reduced (500 images) ImageNet validation dataset.
ARG IMAGENET=full
ARG CK_QAIC_CHECKOUT

# Pull CK repositories.
RUN cd $(ck find repo:ck-qaic) && git checkout ${CK_QAIC_CHECKOUT}
RUN ck pull all

#-----------------------------------------------------------------------------#
# Step 1 . Prepare the dataset.
#-----------------------------------------------------------------------------#
# Download the ImageNet labels.
RUN ck install package --tags=dataset,imagenet,aux --quiet
# Add original ImageNet from an auxiliary image to preprocess it.
COPY --from=imagenet /imagenet /imagenet

RUN if [[ "${IMAGENET}" == "full" ]]; \
  then \
    echo "vfull" | ck detect soft:dataset.imagenet.val --extra_tags=ilsvrc2012,full \
    --full_path="/imagenet/ILSVRC2012_val_00000001.JPEG" && \
    ck install package --tags=dataset,imagenet,val,preprocessed,using-opencv,for.resnet50.quantized,layout.nhwc,side.224,full,validation --quiet; \
  else \
    ck install package --tags=dataset,imagenet,val,min --no_tags=resized --quiet&&  \
    ck install package --tags=dataset,imagenet,val,preprocessed,using-opencv,for.resnet50.quantized,layout.nhwc,side.224 --extra_tags=full,validation --quiet; \
  fi

#-----------------------------------------------------------------------------#
# Step 2. Prepare the ResNet50 workload.
#-----------------------------------------------------------------------------#
# Update ("fix") the input shape from ?x224x224x3 to 1x224x224x3
# to work around a current limitation in the toolchain.
RUN ck install package --tags=dataset,calibration,mlperf.option1 --quiet;
RUN ck install package --tags=dataset,imagenet,calibration,preprocessed,for.resnet50 --quiet;
RUN ck install package --tags=model,tf,mlperf,resnet50,fix_input_shape --quiet

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
COPY --from=builder /imagenet/ILSVRC2012_val_00000001.JPEG /imagenet/ILSVRC2012_val_00000001.JPEG
COPY --from=builder /home/krai/.local /home/krai/.local
COPY --from=builder /home/krai/.bashrc /home/krai/.bashrc
