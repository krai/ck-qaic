# Qualcomm Cloud AI - MLPerf Inference v2.0 audit

## R282-Z93-Q2 results

| Workload      | Offline Accuracy | Offline Performance | SingleStream Accuracy | SingleStream Performance | MultiStream Accuracy | MultiStream Performance |
| ------------- | ---------------- | ------------------- | --------------------- | ------------------------ | -------------------- | ----------------------- |
| ResNet50      |                  |                     |                       |                          |                      |                         |
| SSD-ResNet34  |                  |                     |                       |                          |                      |                         |
| SSD-MobileNet |                  |                     |                       |                          |                      |                         |
| BERT-99       |                  |                     |                       |                          | N/A                  | N/A                     |

# Audit instructions

The instructions below largely follow the [Docker README](https://github.com/krai/ck-qaic/blob/main/docker/README.md), taking note of any important differences in the expected output.

## [System check](https://github.com/krai/ck-qaic/tree/main/docker#system-check)

### [Confirm the Linux kernel v5.4.1](https://github.com/krai/ck-qaic/tree/main/docker#confirm-the-linux-kernel-v541)
```
uname -a
```
<details><pre>
Linux dyson 5.4.1-1.el7.elrepo.x86_64 #1 SMP Fri Nov 29 10:21:13 EST 2019 x86_64 x86_64 x86_64 GNU/Linux
</pre></details>

### [Confirm the presence of QAIC cards](https://github.com/krai/ck-qaic/tree/main/docker#confirm-the-presence-of-qaic-cards)
```
/opt/qti-aic/tools/qaic-version-util
```
<details><pre>
5
</pre></details>

## [Prerequisites](https://github.com/krai/ck-qaic/tree/main/docker#prerequisites)

```
tree /local/mnt/workspace/ -L 2
```
<details><pre>
/local/mnt/workspace/
├── auditor
├── datasets
│   └── imagenet
├── docker [error opening dir]
└── sdks
    ├── qaic-apps-1.6.80.zip
    └── qaic-platform-sdk-1.6.80.zip

5 directories, 2 files
</pre></details>

## [System setup](https://github.com/krai/ck-qaic/blob/main/docker/README.md#system-setup)

### Account setup

```
sudo useradd auditor
sudo passwd auditor
```

```
sudo usermod -aG qaic,root,wheel,docker auditor
sudo mkdir /local/mnt/workspace/auditor
sudo chown auditor:qaic /local/mnt/workspace/auditor
ssh auditor@localhost
```

### Install Python v3.8 (should be already installed)

```
sudo su
export PYTHON_VERSION=3.8.13
cd /usr/src \
&& wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz \
&& tar xzf Python-${PYTHON_VERSION}.tgz \
&& rm -f Python-${PYTHON_VERSION}.tgz \
&& cd /usr/src/Python-${PYTHON_VERSION} \
&& ./configure --enable-optimizations --with-ssl && make -j 32 altinstall \
&& rm -rf /usr/src/Python-${PYTHON_VERSION}*
```

```
python3.8 --version
```
<details><pre>
Python 3.8.13
</pre></details>

## [User setup](https://github.com/krai/ck-qaic/blob/main/docker/README.md#user-setup)

**TODO**

## [Build Docker images](https://github.com/krai/ck-qaic/blob/main/docker/README.md#build-a-docker-image)

### [Base](https://github.com/krai/ck-qaic/blob/main/docker/base/README.md)

**TODO**

### [ImageNet](https://github.com/krai/ck-qaic/blob/main/docker/imagenet/README.md)

```
DATASETS_DIR=/local/mnt/workspace/datasets $(ck find ck-qaic:docker:imagenet)/build.sh
```

<details><pre>
Sending build context to Docker daemon  6.747GB
Step 1/2 : FROM centos:7
7: Pulling from library/centos
2d473b07cdd5: Pull complete
Digest: sha256:c73f515d06b0fa07bb18d8202035e739a494ce760aa73129f60f4bf2bd22b407
Status: Downloaded newer image for centos:7
 ---> eeb6ee3f44bd
Step 2/2 : ADD imagenet /imagenet
 ---> 8b50031cf317
Successfully built 8b50031cf317
Successfully tagged imagenet:latest

real    3m18.980s
user    0m16.976s
sys     0m11.106s

Done.
</pre></details>

```
docker image ls imagenet
```

<details><pre>
EPOSITORY   TAG       IMAGE ID       CREATED              SIZE
imagenet     latest    8b50031cf317   About a minute ago   6.91GB
</pre></details>

### [ResNet50](https://github.com/krai/ck-qaic/blob/main/docker/resnet50/README.md)

#### SDK-independent
```
CK_QAIC_CHECKOUT=v2.0 $(ck find repo:ck-qaic)/docker/build_ck.sh resnet50
```

```
docker image ls krai/*resnet50*
```
<details><pre>
REPOSITORY                 TAG       IMAGE ID       CREATED         SIZE
krai/ck.resnet50.centos7   latest    11ee9bfb3c50   9 minutes ago   13.5GB
</pre></details>

#### SDK-dependent [TODO]
```
CK_QAIC_CHECKOUT=v2.0 $(ck find repo:ck-qaic)/docker/build.sh resnet50
```

### [SSD-ResNet34](https://github.com/krai/ck-qaic/blob/main/docker/ssd-resnet34/README.md)

**TODO**

### [SSD-MobileNet](https://github.com/krai/ck-qaic/blob/main/docker/ssd-mobilenet/README.md)

**TODO**

### [BERT-99](https://github.com/krai/ck-qaic/blob/main/docker/bert/README.md)

**TODO**

## [Benchmark](https://github.com/krai/ck-qaic/blob/main/script/run/README.md#q2)

**TODO**
