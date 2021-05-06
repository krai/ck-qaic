# AI Model Efficiency Toolkit (AIMET)

<a href="https://quic.github.io/aimet-pages/index.html">AIMET</a> is a library
that provides advanced model quantization and compression techniques for
trained neural network models.  It provides features that have been proven to
improve run-time performance of deep learning neural network models with lower
compute and memory requirements and minimal impact to task accuracy.

<a name="prereqs"></a>
# Prerequisites

<a name="prereqs_cpu"></a>
## CPU

None?

<a name="prereqs_gpu"></a>
## GPU (tested on Ubuntu 20.04.2)

```
# apt install -y \
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
# apt install -y \
nvidia-kernel-source-460-server \
nvidia-compute-utils-460
```

### Driver 465 (CUDA 11.3)

```
# apt install -y \
nvidia-kernel-source-465 \
nvidia-compute-utils-465
```

<a name="install"></a>
# Installation

<a name="install_cpu"></a>
## CPU

```bash
$ ck install package --tags=lib,aimet
```

<a name="install_gpu"></a>
## GPU

```bash
$ ck install package --tags=lib,aimet,with-cuda
```
