###############################################################################
# PREABMLE STAGE
###############################################################################
ARG BASE_IMAGE=krai/qaic.centos7
ARG SDK_VER=1.6.16
FROM $BASE_IMAGE:${SDK_VER} AS preamble

ARG PYTHON_VER=3.8.11
ARG GCC_MAJOR_VER=10
ARG CK_VER=2.5.8
ARG CK_QAIC_CHECKOUT=main

#USER krai:kraig
#WORKDIR /home/krai

###############################################################################
### BUILDER STAGE
###############################################################################
FROM preamble AS builder

ARG CK_VER=2.5.8
ARG GCC_MAJOR_VER=10
ARG PYTHON_VER=3.8.11
ARG CK_QAIC_CHECKOUT=main


# Work out the subversions of Python and place them into the Bash resource file.
RUN /bin/bash -l -c  \
 'echo export PYTHON_MAJOR_VER="$(echo ${PYTHON_VER} | cut -d '.' -f1)" >> /home/krai/.bashrc;\
  echo export PYTHON_MINOR_VER="$(echo ${PYTHON_VER} | cut -d '.' -f2)" >> /home/krai/.bashrc;\
  echo export PYTHON_PATCH_VER="$(echo ${PYTHON_VER} | cut -d '.' -f3)" >> /home/krai/.bashrc' \
 && source /home/krai/.bashrc \
 && /bin/bash -l -c \
 'echo export CK_PYTHON="python${PYTHON_MAJOR_VER}.${PYTHON_MINOR_VER}" >> /home/krai/.bashrc'

# Install Collective Knowledge (CK).
RUN git config --global user.name ${GIT_USER} && git config --global user.email ${GIT_EMAIL}
RUN git clone --branch V${CK_VER} https://github.com/ctuning/ck.git ${CK_ROOT}
RUN cd ${CK_ROOT} \
 && source /home/krai/.bashrc \
 && ${CK_PYTHON} setup.py install --user\
 && ${CK_PYTHON} -c "import ck.kernel as ck; print ('Collective Knowledge v%s' % ck.__version__)" \
 && chmod -R g+rx /home/krai/.local

# Explicitly create a CK experiment entry, a folder that will be mounted
# (with '--volume=<folder_for_results>:/home/krai/CK_REPOS/local/experiment').
# as a shared volume between the host and the container, and make it group-writable.
# For consistency, use the "canonical" uid from ck-analytics:module:experiment.
RUN ck create_entry --data_uoa=experiment --data_uid=bc0409fb61f0aa82 --path=${CK_REPOS}/local\
 && chmod -R g+ws ${CK_REPOS}/local/experiment

# Pull CK repositories (including ck-mlperf and ck-env).
RUN ck pull repo --url=https://github.com/krai/ck-qaic

#Detect Python interpreter, install the latest package installer (pip) and implicit dependencies.
RUN source /home/krai/.bashrc \
 && ck detect soft:compiler.python --full_path=$(which ${CK_PYTHON}) \
 && ${CK_PYTHON} -m pip install --user --ignore-installed pip setuptools \
 && ${CK_PYTHON} -m pip install --user wheel pyyaml testresources

# Detect C/C++ compiler (gcc).
RUN ck detect soft:compiler.gcc --full_path=$(scl enable devtoolset-${GCC_MAJOR_VER} 'which ${CK_CC}')

# Install CMake.
RUN ck install package --tags=tool,cmake,downloaded --quiet

# Install explicit dependencies.
RUN ck install package --tags=python-package,cython \
 && ck install package --tags=python-package,absl \
 && ck install package --tags=python-package,matplotlib --quiet \
 && ck install package --tags=python-package,opencv-python-headless \
 && echo "latest" | ck install package --tags=python-package,numpy

RUN ck install package --tags=mlperf,inference,source --quiet \
 && ck install package --tags=mlperf,loadgen,static \
 && ck install package --tags=mlperf,power,source --quiet


###############################################################################
### FINAL STAGE
###############################################################################
FROM preamble AS final

COPY --from=builder /home/krai/CK /home/krai/CK
COPY --from=builder /home/krai/CK_REPOS /home/krai/CK_REPOS
COPY --from=builder /home/krai/CK_TOOLS /home/krai/CK_TOOLS
COPY --from=builder /home/krai/.local /home/krai/.local
COPY --from=builder /home/krai/.bashrc /home/krai/.bashrc


CMD ["/opt/qti-aic/tools/qaic-util -q | grep Status"]
