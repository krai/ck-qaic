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
# Step 1. Download the validation and training (for calibration) datasets.
#-----------------------------------------------------------------------------#
RUN ck install package --tags=dataset,coco.2017,val --quiet
RUN ck install package --tags=dataset,coco.2017,train --quiet
RUN ck install package --tags=dataset,coco,2017,calibration,mlperf

#-----------------------------------------------------------------------------#
# Step 2. Remove 'heavy' items, but only the contents so not to disturb THE FORCE.
#-----------------------------------------------------------------------------#
RUN if [[ "${DEBUG_BUILD}" != "yes" ]]; then rm -rf \
$(ck locate env --tags=dataset,coco.2017,train,original)/* \
$(ck locate env --tags=dataset,coco.2017,val,original)/annotations/*train*; fi

###############################################################################
# FINAL STAGE
#
# In this stage, simply copy CK, CK_TOOLS, CK_REPOS to the final image.
#
###############################################################################
FROM preamble AS final
COPY --from=builder /home/krai/CK_TOOLS /home/krai/CK_TOOLS
COPY --from=builder /home/krai/CK_REPOS /home/krai/CK_REPOS

CMD ["ck show env --tags=dataset,coco.2017,val; ck show env --tags=dataset,coco,2017,calibration,mlperf"]
