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
ARG CK_QAIC_PAT
ARG CK_QAIC_REPO
ARG CK_QAIC_CHECKOUT

#-----------------------------------------------------------------------------#
# Step 0. Update CK repositories.
#-----------------------------------------------------------------------------#
RUN if [[ ! -z ${CK_QAIC_PAT} ]]; then echo ${CK_QAIC_PAT} | gh auth login --with-token; gh auth setup-git; fi
RUN cd ${CK_REPOS}/${CK_QAIC_REPO} && git checkout ${CK_QAIC_CHECKOUT} && ck pull all

#-----------------------------------------------------------------------------#
# Step 1. Install implicit Python dependencies.
#-----------------------------------------------------------------------------#
ARG PYTHON_MAJOR_VER
ARG PYTHON_MINOR_VER
ARG PYTHON_PATCH_VER
ENV CK_PYTHON=python${PYTHON_MAJOR_VER}.${PYTHON_MINOR_VER}

RUN ${CK_PYTHON} -m pip install --user \
pybind11 tqdm protobuf==3.20.1 onnx-simplifier==0.3.7 \
torch==1.8.1 torchvision==0.9.1 pillow==8.3.2

#-----------------------------------------------------------------------------#
# Step 2. Install explicit Python dependencies.
#-----------------------------------------------------------------------------#
RUN ck install package --tags=python-package,onnx,for.qaic --force_version=1.8.1 --quiet \
 && ck install package --tags=python-package,tensorflow --quiet \
 && ck install package --tags=tool,coco --quiet

#-----------------------------------------------------------------------------#
# Step 3. Download the validation and calibration datasets.
#-----------------------------------------------------------------------------#
RUN ${CK_PYTHON} -m pip install --user opencv-python-headless pandas boto3 requests
RUN ck install package --tags=dataset,openimages,original,validation
RUN ck install package --tags=dataset,openimages,original,calibration,mlperf

#-----------------------------------------------------------------------------#
# Step 4. Preprocess the validation and calibration dataset for RetinaNet.
#-----------------------------------------------------------------------------#
RUN ck install package \
--tags=dataset,openimages,validation,full,preprocessed,for.retinanet.onnx.preprocessed.quantized
RUN ck install package \
--tags=dataset,openimages,calibration,mlperf,for.retinanet.onnx.preprocessed,using-various

#-----------------------------------------------------------------------------#
# Step 5. Prepare the RetinaNet workload.
#-----------------------------------------------------------------------------#
RUN ck install package --tags=model,onnx,retinanet,no-nms --quiet

#-----------------------------------------------------------------------------#
# Step 6. Remove 'heavy' items, but only the contents so not to disturb THE FORCE.
#-----------------------------------------------------------------------------#
RUN if [[ "${DEBUG_BUILD}" != "yes" ]]; then rm -rf \
$(ck locate env --tags=dataset,openimages,original,validation)/validation \
$(ck locate env --tags=dataset,openimages,original,calibration)/train; fi

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

CMD ["ck show env --tags=model,onnx,retinanet,no-nms"]
