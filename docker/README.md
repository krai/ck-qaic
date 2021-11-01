# Qualcomm Cloud AI - MLPerf Inference benchmarking using Docker

We provide a collection of Docker images to simplify benchmarking of QAIC
implementations of MLPerf Inference workloads. The images have a similar
interface, and can be set up in an automated way.

## Recommended system setup

**NB:** Can be skipped on `pr006`, `pr009`, `pf002`, `pf003`.

**TODO**

## Recommended user setup

### Set up CK

```
$ python3 -m pip install ck==1.55.5
```

### Set up CK paths

Place the following into your `~/.bashrc`:

```
export PATH=$HOME/.local/bin:$PATH
export CK_REPOS=/local/mnt/workspace/$USER/CK-REPOS
export CK_TOOLS=/local/mnt/workspace/$USER/CK-TOOLS
export CK_EXPERIMENTS=$CK_REPOS/mlperf.$(hostname)/experiment
```

Init it:

```
$ source ~/.bashrc
```

### Create a repository for experimental data

```
$ ck add repo:mlperf.$(hostname) --quiet && \
  ck add mlperf.$(hostname):experiment:dummy --common_func && \
  ck rm  mlperf.$(hostname):experiment:dummy --force
```

Experiments will land into this repository as if by magic!

```
$ ck list repo:mlperf.*
mlperf.aus655-pci-bowie
```

### Make the repository group-writable

All files under `$CK_EXPERIMENTS` must be group-writable:

```
$ chgrp qaic $CK_EXPERIMENTS -R && chmod g+ws $CK_EXPERIMENTS -R
```

### Run a quick test

```
$ docker run --privileged \
--user=krai:kraig --group-add $(cut -d: -f3 < <(getent group qaic)) \
--volume ${CK_EXPERIMENTS}:/home/krai/CK_REPOS/local/experiment \
--rm krai/mlperf.resnet50.full.centos7:1.5.6 \
"ck run cmdgen:benchmark.image-classification.qaic-loadgen --verbose \
--sut=r282_z93_q1 --sdk=1.5.6 --model=resnet50 \
--scenario=offline --mode=accuracy --dataset_size=500 --buffer_size=500"
...
accuracy=75.800%, good=379, total=500
...
```

### Check the results

```
$ ck list mlperf.$(hostname):experiment:mlperf*resnet50*accuracy*dataset_size.500-*
mlperf-closed-r282_z93_q1-qaic-v1.5.6-aic100-resnet50.pcie.16nsp-resnet50-offline-accuracy-dataset_size.500-preprocessed_using.opencv-buffer_size.500

$ grep accuracy\":\ 75 $(ck find experiment:mlperf*resnet50*accuracy*dataset_size.500-*)/*.0001.json
        "accuracy": 75.8,
```
