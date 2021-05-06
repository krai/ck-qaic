# AI Model Efficiency Toolkit (AIMET)

<a href="https://quic.github.io/aimet-pages/index.html">AIMET</a> is a library
that provides advanced model quantization and compression techniques for
trained neural network models.  It provides features that have been proven to
improve run-time performance of deep learning neural network models with lower
compute and memory requirements and minimal impact to task accuracy.

<a name="prereqs"></a>
# Prerequisites

**NB:** The SSD-ResNet34 model is currently calibrated using a particular revision of AIMET.
This revision requires v41 of `setuptools` to be installed:

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> python3 -m pip install setuptools==41.0.1 --user
</pre>

If it is not installed, AIMET installation characteristically fails with:

<pre>
CMake Error at TrainingExtensions/torch/cmake_install.cmake:73 (file):
  file INSTALL cannot find
  "/home/anton/CK-TOOLS/lib-aimet-master-gcc-9.3.0-compiler.python-3.8.5-lib.python.torch-1.4.0-master-linux-64/obj/artifacts/site.py":
  No such file or directory.
</pre>

<a name="prereqs_cpu"></a>
## CPU

None?

<a name="prereqs_gpu"></a>
## GPU (tested on Ubuntu 20.04.2)

```
$ sudo apt install -y \
python3.6-dev \
pybind11-dev \
libilmbase-dev \
libopenexr-dev \
libgstreamer1.0-dev \
libavresample-dev \
gfortran \
ffmpeg
```

### Driver 460 (CUDA 11.2)

```
$ sudo apt install -y nvidia-driver-460-server nvidia-kernel-source-460-server nvidia-compute-utils-460
```

### Driver 465 (CUDA 11.3)

```
$ sudo apt install -y nvidia-driver-465 nvidia-kernel-source-465 nvidia-compute-utils-465
```

<a name="install"></a>
# Installation

<a name="install_cpu"></a>
## CPU

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> ck install package --tags=lib,aimet
</pre>

<a name="install_gpu"></a>
## GPU

<pre>
<b>[anton@krai ~]&dollar;</b> ck install package --tags=lib,aimet,with-cuda
</pre>
