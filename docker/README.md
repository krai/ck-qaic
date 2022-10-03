:toc:
:toclevels: 3
:sectnums:

# Qualcomm Cloud AI - MLPerf Inference - Docker

## Conventions

Throughout this document, we provide commands which can typically be copied (left-click on the icon) and pasted (right-click in the terminal) verbatim, for example:
```
uname -a
```
Sometimes, we also include sample output which can be expanded by clicking on "Details", for example:
<details><pre>
Linux dyson 5.4.1-1.el7.elrepo.x86_64 #1 SMP Fri Nov 29 10:21:13 EST 2019 x86_64 x86_64 x86_64 GNU/Linux
</pre></details>

## System check

Please refer to the Qualcomm Cloud AI 100 Platform SDK User Guide document (80-PT790-31) to set up your server with CentOS 7 (with the Linux kernel v5.4.1) or Ubuntu 20.04. We assume using the `bash` shell with either Linux OS.

### Check the OS

#### CentOS 7

##### Confirm the CentOS release 7
```
rpm -q centos-release
```
<details><pre>
centos-release-<b>7</b>-9.2009.1.el7.centos.x86_64
</pre></details>

##### Confirm the Linux kernel v5.4.1
```
uname -a
```
<details><pre>
Linux aus655-perf-g292-3 <b>5.4.1</b>-1.el7.elrepo.x86_64 #1 SMP Thu Mar 25 11:08:18 UTC 2021 x86_64 x86_64 x86_64 GNU/Linux
</pre></details>

#### Ubuntu 20.04

##### Confirm the Ubuntu release
```
cat /etc/lsb-release
```
<details><pre>
DISTRIB_ID=Ubuntu
DISTRIB_RELEASE=20.04
DISTRIB_CODENAME=focal
DISTRIB_DESCRIPTION="Ubuntu 20.04.3 LTS"
</pre></details>

##### Confirm the Linux kernel
```
uname -a
```
<details><pre>
Linux velociti <b>5.11.0</b>-43-generic #47~20.04.2-Ubuntu SMP Mon Dec 13 11:06:56 UTC 2021 x86_64 x86_64 x86_64 GNU/Linux
</pre>
(We have tested only with the Linux kernel v5.10.0 and v5.11.0.)
</details>


### Confirm the shell
```
echo $SHELL
```
<details><pre>
/bin/bash
</pre></details>

### Confirm the presence of QAIC cards
```
/opt/qti-aic/tools/qaic-util -q | grep -c Ready
```
<details><pre>
16
</pre></details>

### Confirm the QAIC SDK version on the host
```
/opt/qti-aic/tools/qaic-version-util
```
<details><pre>
platform:AIC.<b>1.6.80</b>
apps:AIC.<b>1.6.80</b>
factory:not found
</pre></details>

Note that the SDK version on the host does not have to match the SDK version in the image exactly, but should usually be close enough.

## Prerequisites

We assume that the user has access to permanent file storage e.g. `/local/mnt/workspace` or `/home/user` (to be defined by the environment variable `$WORKSPACE`).
This storage should have at least 100G free.

### Locate the QAIC SDKs

Place the Platform and Apps SDKs under `$WORKSPACE/sdks` e.g.:
```
ls -la $WORKSPACE/sdks/*1.6.80.zip
```
<details><pre>
-rw-r--r-- 1 alokhmot users  306516755 Dec 17 05:38 /local/mnt/workspace/sdks/qaic-apps-1.6.80.zip
-rw-r--r-- 1 alokhmot users 1424395295 Dec 17 05:44 /local/mnt/workspace/sdks/qaic-platform-sdk-aarch64-1.6.80.zip
-rw-r--r-- 1 alokhmot users 1403362233 Dec 17 05:47 /local/mnt/workspace/sdks/qaic-platform-sdk-x86_64-1.6.80.zip
</pre></details>

### [Optional] Locate the ImageNet dataset

Place the ImageNet 2012 validation dataset (50,000 images) under `$WORKSPACE/datasets/imagenet` e.g.:
```
du -hs $WORKSPACE/datasets/imagenet/
```
<details><pre>
6.4G    /local/mnt/workspace/datasets/imagenet/
</pre></details>

## System setup

We assume that the user (as defined by the system environment variable `$USER`) has administrator level permissions e.g. can install packages via `sudo`.

### CentOS 7

#### Install system packages

```
sudo yum upgrade -y
sudo yum install -y \
  git wget patch vim which \
  zip unzip bzip2-devel \
  openssl-devel libffi-devel \
  lm_sensors ipmitool \
  yum-utils lvm2 device-mapper-persistent-data \
  dnf acl
sudo yum clean all
sudo dnf install python3 python3-pip python3-devel
```

#### Install Docker
```
sudo yum remove -y docker docker-common
sudo yum-config-manager -y --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum list docker-ce --showduplicates | grep @docker-ce-stable
```
<details><pre>
docker-ce.x86_64            3:20.10.14-3.el7                   @docker-ce-stable
</pre></details>

```
sudo yum install -y docker-ce-20.10.14-3.el7
```
<details><pre>
...
Installed:
  docker-ce.x86_64 3:20.10.14-3.el7

Dependency Installed:
  docker-ce-rootless-extras.x86_64 0:20.10.14-3.el7

Complete!
</pre></details>

#### [Optional] Change the Docker storage location

Customize the workspace location e.g.:
```
export WORKSPACE=/local/mnt/workspace
export WORKSPACE_DOCKER=$WORKSPACE/docker
```

Create `override.conf` (back up if exists):
```
sudo mkdir -p $WORKSPACE_DOCKER
sudo mkdir -p /etc/systemd/system/docker.service.d/
sudo cp /etc/systemd/system/docker.service.d/override.conf{,.bak}
echo -e "[Service]\nExecStart=\nExecStart=/usr/bin/dockerd --graph=$WORKSPACE_DOCKER --storage-driver=overlay2" | \
sudo tee -a /etc/systemd/system/docker.service.d/override.conf
cat /etc/systemd/system/docker.service.d/override.conf
```
<details><pre>
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd --graph=<b>/local/mnt/workspace/docker</b> --storage-driver=overlay2
</pre></details>

#### Start Docker
```
sudo systemctl enable docker
sudo systemctl start docker
docker system info
```
<details><pre>
Client:
 Context:    default
 Debug Mode: false
 Plugins:
  app: Docker App (Docker Inc., v0.9.1-beta3)
  buildx: Docker Buildx (Docker Inc., v0.7.1-docker)
  scan: Docker Scan (Docker Inc., v0.12.0)

Server:
 Containers: 0
  Running: 0
  Paused: 0
  Stopped: 0
 Images: 397
 Server Version: 20.10.12
 Storage Driver: overlay2
  Backing Filesystem: extfs
  Supports d_type: true
  Native Overlay Diff: true
  userxattr: false
 Logging Driver: json-file
 Cgroup Driver: cgroupfs
 Cgroup Version: 1
 Plugins:
  Volume: local
  Network: bridge host ipvlan macvlan null overlay
  Log: awslogs fluentd gcplogs gelf journald json-file local logentries splunk syslog
 Swarm: inactive
 Runtimes: io.containerd.runc.v2 io.containerd.runtime.v1.linux runc
 Default Runtime: runc
 Init Binary: docker-init
 containerd version: 7b11cfaabd73bb80907dd23182b9347b4245eb5d
 runc version: v1.0.2-0-g52b36a2
 init version: de40ad0
  Security Options:
  seccomp
   Profile: default
 <b>Kernel Version: 5.4.1-1.el7.elrepo.x86_64</b>
 <b>Operating System: CentOS Linux 7 (Core)</b>
 OSType: linux
 Architecture: x86_64
 CPUs: 256
 Total Memory: 1008GiB
 Name: aus655-perf-g292-3
 ID: X4WT:2EDI:2EHL:PZKO:LEDE:PJMG:4KOV:66YH:R4V4:RZRF:6YAY:AXQG
 <b>Docker Root Dir: /local/mnt/workspace/docker</b>
 Debug Mode: false
 Registry: https://index.docker.io/v1/
 Labels:
 Experimental: false
 Insecure Registries:
  127.0.0.0/8
 Live Restore Enabled: false

WARNING: bridge-nf-call-iptables is disabled
WARNING: bridge-nf-call-ip6tables is disabled
</pre></details>

### Ubuntu 20.04

#### Install system packages (may be incomplete)

```
sudo apt upgrade -y
sudo apt install -y \
  git wget patch vim \
  libbz2-dev lzma \
  python3-dev python3-pip \
  lm-sensors ipmitool \
  acl
sudo apt clean all
```

#### Install Docker
```
sudo apt install docker-ce
docker --version
```
<details><pre>
Docker version 20.10.12, build e91ed57
</pre></details>

#### [Optional] Change the Docker storage location

Customize the workspace location e.g.:
```
export WORKSPACE=/local/mnt/workspace
export WORKSPACE_DOCKER=$WORKSPACE/docker
export DOCKER_DAEMON_JSON=/etc/docker/daemon.json
```

Create `daemon.json` (back up if exists):
```
sudo mkdir -p $WORKSPACE_DOCKER
sudo cp $DOCKER_DAEMON_JSON{,.bak}
echo -e "{\n\t\"data-root\": \"$WORKSPACE_DOCKER\"\n}" | sudo tee -a $DOCKER_DAEMON_JSON
cat $DOCKER_DAEMON_JSON
```
<details><pre>
{
        "data-root": "/data/docker"
}
</pre></details>

#### Start Docker
```
sudo service docker start
docker system info
```
<details><pre>
Client:              
 Context:    default
 Debug Mode: false          
 Plugins:
  app: Docker App (Docker Inc., v0.9.1-beta3)
  buildx: Docker Buildx (Docker Inc., v0.7.1-docker)
  scan: Docker Scan (Docker Inc., v0.12.0)

Server:
 Containers: 1
  Running: 0
  Paused: 0
  Stopped: 1
 Images: 85
 Server Version: 20.10.12
 Storage Driver: overlay2
  Backing Filesystem: extfs
  Supports d_type: true
  Native Overlay Diff: true
  userxattr: false
 Logging Driver: json-file
 Cgroup Driver: cgroupfs
 Cgroup Version: 1
 Plugins:
  Volume: local
  Network: bridge host ipvlan macvlan null overlay 
  Log: awslogs fluentd gcplogs gelf journald json-file local logentries splunk syslog
 Swarm: inactive
 Runtimes: io.containerd.runc.v2 io.containerd.runtime.v1.linux runc
 Default Runtime: runc
 Init Binary: docker-init
 containerd version: 7b11cfaabd73bb80907dd23182b9347b4245eb5d
 runc version: v1.0.2-0-g52b36a2
 init version: de40ad0
 Security Options:
  apparmor
  seccomp
   Profile: default
<b> Kernel Version: 5.11.0-43-generic</b>
<b> Operating System: Ubuntu 20.04.3 LTS</b>
 OSType: linux
 Architecture: x86_64
 CPUs: 20
 Total Memory: 31.26GiB
 Name: velociti
 ID: 7PDG:57WO:5TRQ:A5HC:WZ6M:FSZW:C4EV:VAOF:I5R2:QUQZ:GXPQ:FUR2
<b> Docker Root Dir: /data/docker</b>
 Debug Mode: false
 Registry: https://index.docker.io/v1/
  Labels:
 Experimental: false
 Insecure Registries:
  127.0.0.0/8
 Live Restore Enabled: false
</pre></details>

## User setup

### Add the user to the required groups
```
sudo usermod -aG qaic,docker,wheel $USER
```

### Set up the user environment

Customize the workspace:
```
export WORKSPACE_DIR=/local/mnt/workspace
```

Add environment variables to `~/.bashrc`:
```
echo -n "\
export CK_PYTHON=${CK_PYTHON:-$(which python3)}
export CK_WORKSPACE=$WORKSPACE_DIR
export CK_TOOLS=$WORKSPACE_DIR/$USER/CK-TOOLS
export CK_REPOS=$WORKSPACE_DIR/$USER/CK-REPOS
export CK_EXPERIMENT_REPO=mlperf_v2.0.$(hostname).$USER
export CK_EXPERIMENT_DIR=$WORKSPACE_DIR/$USER/CK-REPOS/mlperf_v2.0.$(hostname).$USER/experiment
export PATH=$HOME/.local/bin:$PATH" >> ~/.bashrc
source ~/.bashrc
```

### Create a user directory in the workspace
```
sudo mkdir -p $CK_WORKSPACE/$USER && sudo chown $USER:qaic $CK_WORKSPACE/$USER
```

### Set up Collective Knowledge
```
$CK_PYTHON -m pip install --ignore-installed pip setuptools testresources ck==2.6.1 --user --upgrade
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
/local/mnt/workspace/alokhmot/CK-REPOS/mlperf_v2.0.aus655-perf-g292-3.alokhmot/experiment:
total 12
drwxrwsr-x+ 3 alokhmot qaic  4096 Dec 16 09:05 .
drwxr-sr-x  4 alokhmot users 4096 Dec 16 08:59 ..
drwxrwsr-x+ 2 alokhmot qaic  4096 Dec 16 09:02 .cm
-rw-rw-r--+ 1 alokhmot qaic     0 Dec 16 09:07 TEST
</pre><pre>
/local/mnt/workspace/alokhmot/CK-REPOS/mlperf_v2.0.aus655-perf-g292-3.alokhmot/experiment/.cm:
total 8
drwxrwsr-x+ 2 alokhmot qaic 4096 Dec 16 09:02 .
drwxrwsr-x+ 3 alokhmot qaic 4096 Dec 16 09:05 ..
</pre></details>

## Build a Docker image

We use our Docker image for BERT as a running example.

For more details, see benchmark-specific instructions:
- [BERT](https://github.com/krai/ck-qaic/blob/main/docker/bert/README.md)
- [ResNet50](https://github.com/krai/ck-qaic/blob/main/docker/resnet50/README.md)
- [RetinaNet](https://github.com/krai/ck-qaic/blob/main/docker/retinanet/README.md)

### Build arguments

The most important build arguments and their default values are provided below:

- `SDK_VER=1.7.1.12`
- `SDK_DIR=/local/mnt/workspace/sdks`
- `WORKSPACE_DIR=/local/mnt/workspace`
- `DOCKER_OS=ubuntu` (only CentOS 7 and Ubuntu 20.04 are supported)
- `PYTHON_VER=3.9.14` (Python interpreter)
- `GCC_MAJOR_VER=11` (C++ compiler)
- `CK_QAIC_PERCENTILE_CALIBRATION=no` (see below)
- `CK_QAIC_PCV=9980` (PCV stands for percentile calibration value, see below)
- `CK_VER=2.6.1` ([MLCommons Collective Knowledge](https://github.com/mlcommons/ck))
- `COMPILE_PRO=yes` (compilation for PCIe Pro server cards)
- `COMPILE_STD=no`  (compilation for PCIe Standard server cards) 
- `DEBUG_BUILD=no` (DEBUG_BUILD=yes builds a larger image with support for model compilation)

### Build commands

#### Default PCV (~1 hour)
```
WORKSPACE_DIR=/local/mnt/workspace SDK_VER=1.7.1.12 COMPILE_PRO=yes COMPILE_STD=no DOCKER_OS=ubuntu $(ck find repo:ck-qaic)/docker/build.sh bert
```

##### Check
```
docker image prune && docker image ls | head -n 6
```
<details><pre>
REPOSITORY                          TAG            IMAGE ID       CREATED          SIZE
krai/mlperf.bert            ubuntu_1.7.1.12       5b6603e9533a   2 minutes ago    6.14GB
krai/ck.bert                ubuntu_latest         dc63f7469ed0   16 minutes ago   11GB
krai/ck.common              ubuntu_latest         1df24def6e4b   33 minutes ago   2.43GB
krai/base                   ubuntu_latest         b136531dce5d   37 minutes ago   1GB
krai/qaic                   ubuntu_1.7.1.12       6fff1756e9f4   45 minutes ago   2.22GB
</pre>

The images tagged with `1.7.1.12` are SDK-dependent, and need to be rebuilt with newer SDKs.
The images tagged with `latest` are SDK-independent, and can be reused with newer SDKs.
</details>

#### Given PCV (~1 hour)
```
WORKSPACE_DIR=/local/mnt/workspace SDK_VER=1.7.1.12 COMPILE_PRO=yes COMPILE_STD=no DOCKER_OS=ubuntu CK_QAIC_PCV=9980 $(ck find repo:ck-qaic)/docker/build.sh bert
```
Note that `CK_QAIC_PCV` cannot be specified together with `CK_QAIC_PERCENTILE_CALIBRATION=yes` (`no` by default).

#### Exploration of best PCV (~2 hours)
```
WORKSPACE_DIR=/local/mnt/workspace SDK_VER=1.7.1.12 COMPILE_PRO=yes COMPILE_STD=no DOCKER_OS=ubuntu CK_QAIC_PERCENTILE_CALIBRATION=yes $(ck find repo:ck-qaic)/docker/build.sh bert
```
Note that `CK_QAIC_PERCENTILE_CALIBRATION=yes` cannot be specified together with `CK_QAIC_PCV`.

##### Check
```
docker image prune && docker image ls | head -n 9
```
<details><pre>
REPOSITORY                          TAG            IMAGE ID       CREATED             SIZE
krai/mlperf.bert            ubuntu_1.7.1.12         074289ee7fac   4 minutes ago       6.36GB
krai/mlperf.bert            ubuntu_1.7.1.12_PC      c4bc6ea9f83d   6 minutes ago       14.2GB
krai/mlperf.bert            ubuntu_1.7.1.12_DEBUG   f5ea6d335c9f   About an hour ago   13.6GB
<none>                              <none>                      5b6603e9533a   3 hours ago         6.14GB
krai/ck.bert                ubuntu_latest           dc63f7469ed0   3 hours ago         11GB
krai/ck.common              ubuntu_latest           1df24def6e4b   3 hours ago         2.43GB
krai/base                   ubuntu_latest           b136531dce5d   3 hours ago         1GB
krai/qaic                   ubuntu_1.7.1.12         6fff1756e9f4   4 hours ago         2.22GB
</pre>

Note the new auxiliary images tagged with `ubuntu_1.7.1.12_PC` and `ubuntu_1.7.1.12_DEBUG`, which can be removed. The image with id `5b6603e9533a` is the previously built (and now untagged) `krai/mlperf.bert:ubuntu_1.7.1.12 with the default PCV.
</details>
