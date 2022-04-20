# Qualcomm Cloud AI - MLPerf Inference v2.0 audit - GIGABYTE R282-Z93-Q2

The [submitted](https://github.com/mlcommons/inference_results_v2.0/tree/master/closed/GIGABYTE/results/r282_z93_q2-qaic-v1.6.80-aic100) results were obtained on two cards (Q2) of a R282-Z93 server with five cards (Q5). The reproduced results were obtained on a similar server. The main difference between the servers was the amount of RAM: 512G (64G x8) vs 128 (32G x4).

| Workload      | Results    | Offline Accuracy | Offline Performance | SingleStream Accuracy | SingleStream Performance | MultiStream Accuracy | MultiStream Performance |
| ------------- | ---------- | ---------------- | ------------------- | --------------------- | ------------------------ | -------------------- | ----------------------- |
| ResNet50      | Submitted  |   75.956               |   46,361.40                  |    75.956                   |    0.34                      |    75.956                  |    0.64                     |
| ResNet50      | Reproduced |                  |                     |                       |                          |                      |                         |
| SSD-ResNet34  | Submitted  |    19.831              |     885.04                |   19.831                    |    8.73                      |    19.831                  |    28.03                     |
| SSD-ResNet34  | Reproduced |                  |                     |                       |                          |                      |                         |
| SSD-MobileNet | Submitted  |   23.160               |    38,630.30                 |   23.160                    |    0.68                      |   23.160                   |    1.52                     |
| SSD-MobileNet | Reproduced |                  |                     |                       |                          |                      |                         |
| BERT-99       | Submitted  |    90.363              |    1,437.71                 |   90.332                    |    10.25                      | N/A                  | N/A                     |
| BERT-99       | Reproduced |                  |                     |                       |                          | N/A                  | N/A                     |

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
platform:AIC.1.6.80
apps:AIC.1.6.80
factory:not found
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

### Install Git v2.x (should already be installed)

Follow steps [here](https://www.endpointdev.com/blog/2021/12/installing-git-2-on-centos-7/).

```
git --version
```
<details><pre>
git version 2.34.1
</pre></details>

## [User setup](https://github.com/krai/ck-qaic/blob/main/docker/README.md#user-setup)

### Set up the user environment

Customize the workspace:
```
export WORKSPACE=/local/mnt/workspace
```

Add environment variables to `~/.bashrc`:

```
echo -n "\
export CK_PYTHON=${CK_PYTHON:-$(which python3)}
export CK_WORKSPACE=$WORKSPACE
export CK_TOOLS=$WORKSPACE/$USER/CK-TOOLS
export CK_REPOS=$WORKSPACE/$USER/CK-REPOS
export CK_EXPERIMENT_REPO=mlperf_v2.0.$(hostname).$USER
export CK_EXPERIMENT_DIR=$WORKSPACE/$USER/CK-REPOS/mlperf_v2.0.$(hostname).$USER/experiment
export RESOURCES_DIR=/local/mnt/workspace/resources
export PATH=$HOME/.local/bin:$PATH" >> ~/.bashrc
```

Init it:
```
source ~/.bashrc
```

### Create a user directory in the workspace
```
sudo mkdir -p $CK_WORKSPACE/$USER && sudo chown $USER:qaic $CK_WORKSPACE/$USER
```

### Set up Collective Knowledge
```
$CK_PYTHON -m pip install --ignore-installed pip setuptools testresources ck==2.6.1 --user --upgrade
```

```
ck version
```
<details><pre>
V2.6.1
</pre></details>

Pull the `ck-qaic` repository (and, recursively, its dependent repositories):
```
ck pull repo --url=https://github.com/krai/ck-qaic
```

### Set up an experiment directory in the workspace
```
ck add repo:$CK_EXPERIMENT_REPO --quiet
ck add $CK_EXPERIMENT_REPO:experiment:dummy --common_func
ck rm  $CK_EXPERIMENT_REPO:experiment:dummy --force
sudo chgrp -R qaic $CK_EXPERIMENT_DIR
chmod -R g+ws $CK_EXPERIMENT_DIR
setfacl -R -d -m group:qaic:rwx $CK_EXPERIMENT_DIR
```

#### Test
```
touch $CK_EXPERIMENT_DIR/TEST && ls -Rla $CK_EXPERIMENT_DIR && rm $CK_EXPERIMENT_DIR/TEST
```
<details><pre>

/local/mnt/workspace/auditor/CK-REPOS/mlperf_v2.0.dyson.auditor/experiment:
total 24
drwxrwsr-x+ 3 auditor qaic    4096 Mar 31 12:35 .
drwxrwxr-x. 4 auditor auditor 4096 Mar 31 12:34 ..
drwxrwsr-x+ 2 auditor qaic    4096 Mar 31 12:34 .cm
-rw-rw-r--+ 1 auditor qaic       0 Mar 31 12:35 TEST

/local/mnt/workspace/auditor/CK-REPOS/mlperf_v2.0.dyson.auditor/experiment/.cm:
total 16
drwxrwsr-x+ 2 auditor qaic 4096 Mar 31 12:34 .
drwxrwsr-x+ 3 auditor qaic 4096 Mar 31 12:35 ..
</pre></details>


## [Build Docker images](https://github.com/krai/ck-qaic/blob/main/docker/README.md#build-a-docker-image)

### [Base](https://github.com/krai/ck-qaic/blob/main/docker/base/README.md)
**TO VALIDATE**
### Build an SDK-independent base OS image

To build a base OS image including Python and GCC:

```
$(ck find ck-qaic:docker:base)/build.base.sh
```

#### Parameters
- `DOCKER_OS=centos7` (only CentOS 7 is currently supported).
- `PYTHON_VER=3.8.13`.
- `GCC_MAJOR_VER=11`.
- `TIMEZONE=US/Central` (Austin).

#### Test
```
docker run --rm krai/base.centos7
```
<details><pre>
centos-release-7-9.2009.1.el7.centos.x86_64
</pre></details>

### Build an SDK-independent common CK image

To build a base image for CK packages common to all supported MLPerf Inference benchmarks:

```
$(ck find ck-qaic:docker:base)/build.ck.sh
```

#### Parameters
- `DOCKER_OS=centos7`.
- `PYTHON_VER=3.8.13`.
- `GCC_MAJOR_VER=11`.
- `CK_VER=2.6.1`.
- `GROUP_ID=1500`.
- `USER_ID=2000`.

#### Test
```
docker run --rm krai/ck.common.centos7
```
<details><pre>
V2.6.1
</pre></details>

### Build an image for a given QAIC SDK

```
SDK_VER=1.6.80 SDK_DIR=/local/mnt/workspace/sdks/ $(ck find ck-qaic:docker:base)/build.qaic.sh
```

#### Parameters
- `DOCKER_OS=centos7`.
- `SDK_DIR=/local/mnt/workspace/sdks/`.
- `SDK_VER=1.6.80`.
- `PLATFORM_SDK`.
- `APPS_SDK`.

#### Test
```
export SDK_VER=1.6.80 && docker run --privileged --rm krai/qaic.centos7:${SDK_VER}
```
<details><pre>
        Status:Ready
</pre></details>


### [ResNet50](https://github.com/krai/ck-qaic/blob/main/docker/resnet50/README.md)

#### [ImageNet](https://github.com/krai/ck-qaic/blob/main/docker/imagenet/README.md)

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

#### SDK-independent [DONE]
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

#### SDK-dependent [DONE]
```
CK_QAIC_CHECKOUT=v2.0 $(ck find repo:ck-qaic)/docker/build.sh resnet50
```
```
docker image ls krai/*resnet50*
```
<details><pre>
[auditor@dyson ck-qaic]$ docker image ls krai/*resnet50*
REPOSITORY                          TAG       IMAGE ID       CREATED          SIZE
krai/mlperf.resnet50.full.centos7   1.6.80    a33de9c692e9   59 minutes ago   12.3GB
krai/ck.resnet50.centos7            latest    6a9471f3a2ed   2 hours ago      13.5GB
</pre></details>

#### Load the Container
```
CONTAINER_ID=$(ck run cmdgen:benchmark.image-classification.qaic-loadgen --docker=container_only --out=none --sdk=1.6.80 --model_name=resnet50)
```
To see experiments outside of container (--experiment_dir):
```
CONTAINER_ID=$(ck run cmdgen:benchmark.image-classification.qaic-loadgen --docker=container_only --out=none --sdk=1.6.80 --model_name=resnet50 --experiment_dir)
```

#### Quick Accuracy Check
```
ck run cmdgen:benchmark.image-classification.qaic-loadgen --verbose --sut=r282_z93_q1 --sdk=1.6.80 --model=resnet50 --mode=accuracy --scenario=offline --target_qps=22222 --container=$CONTAINER_ID
```

### [SSD-ResNet34](https://github.com/krai/ck-qaic/blob/main/docker/ssd-resnet34/README.md)

#### SDK-independent [DONE]
```
CK_QAIC_CHECKOUT=v2.0 $(ck find repo:ck-qaic)/docker/build_ck.sh ssd-resnet34
```

```
docker image ls krai/*ssd-resnet34*
```
<details><pre>
REPOSITORY                     TAG       IMAGE ID       CREATED         SIZE
krai/ck.ssd-resnet34.centos7   latest    bebaeb96fa93   5 minutes ago   27.5GB
</pre></details>

#### SDK-dependent [DONE]
```
CK_QAIC_CHECKOUT=v2.0 $(ck find repo:ck-qaic)/docker/build.sh ssd-resnet34
```
```
docker image ls krai/*ssd-resnet34*
```
<details><pre>
REPOSITORY                         TAG       IMAGE ID       CREATED          SIZE
krai/mlperf.ssd-resnet34.centos7   1.6.80    4e31315c9cd2   2 minutes ago    25.2GB
krai/ck.ssd-resnet34.centos7       latest    bebaeb96fa93   26 minutes ago   27.5GB
</pre></details>

#### Load the Container
```
CONTAINER_ID=$(ck run cmdgen:benchmark.object-detection-large.qaic-loadgen --docker=container_only --out=none --sdk=1.6.80 --model_name=ssd-resnet34)
```
To see experiments outside of container (--experiment_dir):
```
CONTAINER_ID=$(ck run cmdgen:benchmark.object-detection-large.qaic-loadgen --docker=container_only --out=none --sdk=1.6.80 --model_name=ssd-resnet34 --experiment_dir)
```

#### Quick Accuracy Check
```
ck run cmdgen:benchmark.object-detection-large.qaic-loadgen --verbose --sut=r282_z93_q1 --sdk=1.6.80 --model=ssd_resnet34 --mode=accuracy --scenario=offline --target_qps=425 --container=$CONTAINER_ID
```

### [SSD-MobileNet](https://github.com/krai/ck-qaic/blob/main/docker/ssd-mobilenet/README.md)

#### SDK-independent [DONE]
```
CK_QAIC_CHECKOUT=v2.0 $(ck find repo:ck-qaic)/docker/build_ck.sh ssd-mobilenet
```

```
docker image ls krai/*ssd-mobilenet*
```
<details><pre>
REPOSITORY                      TAG       IMAGE ID       CREATED       SIZE
krai/ck.ssd-mobilenet.centos7   latest    fdd48e3378de   2 hours ago   8.9GB
</pre></details>

#### SDK-dependent [DONE]
```
CK_QAIC_CHECKOUT=v2.0 $(ck find repo:ck-qaic)/docker/build.sh ssd-mobilenet
```
```
docker image ls krai/*ssd-mobilenet*
```
<details><pre>
REPOSITORY                          TAG       IMAGE ID       CREATED         SIZE
krai/mlperf.ssd-mobilenet.centos7   1.6.80    9db636a770c1   6 minutes ago   6.35GB
krai/ck.ssd-mobilenet.centos7       latest    fdd48e3378de   2 hours ago     8.9GB
</pre></details>

#### Load the Container
```
CONTAINER_ID=$(ck run cmdgen:benchmark.object-detection-small.qaic-loadgen --docker=container_only --out=none --sdk=1.6.80 --model_name=ssd-mobilenet)
```
To see experiments outside of container (--experiment_dir):
```
CONTAINER_ID=$(ck run cmdgen:benchmark.object-detection-small.qaic-loadgen --docker=container_only --out=none --sdk=1.6.80 --model_name=ssd-mobilenet --experiment_dir)
```

#### Quick Accuracy Check
```
ck run cmdgen:benchmark.object-detection-small.qaic-loadgen --verbose --sut=r282_z93_q1 --sdk=1.6.80 --model=ssd_mobilenet --mode=accuracy --scenario=offline --target_qps=19500 --container=$CONTAINER_ID
```

### [BERT-99](https://github.com/krai/ck-qaic/blob/main/docker/bert/README.md)

#### SDK-dependent [DONE]
```
CK_QAIC_CHECKOUT=v2.0 CK_QAIC_PCV=9983 SDK_DIR=/local/mnt/workspace/mlcommons/sdks $(ck find repo:ck-qaic)/docker/build.sh bert
```
```
docker image ls krai/*bert*
```

<details><pre>
REPOSITORY                 TAG       IMAGE ID       CREATED          SIZE
krai/mlperf.bert.centos7   1.6.80    550bbbcf9f91   10 minutes ago   7GB
krai/ck.bert.centos7       latest    a89ab03b895b   45 minutes ago   13.1GB
</pre></details>

#### SDK-independent

This image is independent of SDK and is automatically created by the Docker build of the main image
```
CK_QAIC_CHECKOUT=v2.0 $(ck find repo:ck-qaic)/docker/build_ck.sh bert
```

#### Load the Container
```
CONTAINER_ID=$(ck run cmdgen:benchmark.packed-bert.qaic-loadgen --docker=container_only --out=none --sdk=1.6.80 --model_name=bert)
```
To see experiments outside of container (--experiment_dir):
```
CONTAINER_ID=$(ck run cmdgen:benchmark.packed-bert.qaic-loadgen --docker=container_only --out=none --sdk=1.6.80 --model_name=bert --experiment_dir)
```
#### Quick Accuracy Check
```
ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose --sut=r282_z93_q1 --sdk=1.6.80 --model=bert-99 --mode=accuracy --scenario=offline --target_qps=650 --container=$CONTAINER_ID
```

## [Benchmark](https://github.com/krai/ck-qaic/blob/main/script/run/README.md#q2)

**TODO**

## Create compliant MLPerf Inference submissions from CK experiments

### List all the experiments

```
ck list mlperf_v2.0.dyson.auditor:experiment:*
```
<details><pre>

</pre></details>

**To remove any of the above experiments**
```
ck rm experiment:<experiment_folder_name>
```

### Clone this repository

```
export SUBMISSIONS_DIR=/local/mnt/workspace/mlperf-inference-submissions
mkdir -p $SUBMISSIONS_DIR
mkdir -p $SUBMISSIONS_DIR/scripts
git clone git@github.com:krai/mlperf-inference $SUBMISSIONS_DIR/scripts/krai-mlperf-inference
```

### Install resources via CK
```
ck detect soft:compiler.python --full_path=$(which python3.8)
ck install package --tags=mlperf,inference,r2.0
ck install package --tags=dataset,coco,val,2017
ck install package --tags=dataset,imagenet,aux,from.berkeley
ck install package --tags=dataset,tokenization,vocab
ck install package --tags=dataset,squad,original
ck install package --tags=dataset,squad,tokenized,pickle
ck install package --tags=lib,python-package,absl
ck install package --tags=lib,python-package,transformers --force_version=2.4.0
```

### Make the resources available for other users (optional)
```
export SUBMISSIONS_DIR=/local/mnt/workspace/mlperf-inference-submissions
export RESOURCES_DIR=$SUBMISSIONS_DIR/resources
mkdir -p $RESOURCES_DIR
cp -r $(ck locate env --tags=mlperf,inference,source,r2.0) $RESOURCES_DIR/
cp -r $(ck locate env --tags=coco,val) $RESOURCES_DIR/
cp $(ck locate env --tags=aux)/val.txt $RESOURCES_DIR/
cp $(ck locate env --tags=vocab,tokenization)/vocab.txt $RESOURCES_DIR/
cp $(ck locate env --tags=squad,original)/dev-v1.1.json $RESOURCES_DIR/
cp $(ck locate env --tags=squad,tokenized,pickle)/bert_tokenized_squad_v1_1.pickle $RESOURCES_DIR/
```

### Install implicit dependences
```
python3.8 -m pip install pandas tabulate pycocotools --user
```

#### Optional (SQL)
```
sudo yum install mariadb-devel
python3.8 -m pip install sqlalchemy mysqlclient --user
```

### Run the Submission Generation Script

Run from the `dump-repo-to-submission` directory (`./run.sh`) or from outside by providing the path to the script.

```
MLPERF_DIV=open CK_REPO=mlperf_v2.0.dyson.auditor SUBMITTER=GIGABYTE ./run.sh
```
<details><pre>

</pre></details>
