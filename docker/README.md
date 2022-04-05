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
- [SSD-ResNet34](https://github.com/krai/ck-qaic/blob/main/docker/ssd-resnet34/README.md)
- [SSD-MobileNet](https://github.com/krai/ck-qaic/blob/main/docker/ssd-mobilenet/README.md)

### Build arguments

The most important build arguments and their default values are provided below:

- `SDK_VER=1.6.80`
- `SDK_DIR=/local/mnt/workspace/sdks`
- `DOCKER_OS=centos7` (only CentOS 7 is supported)
- `PYTHON_VER=3.8.13` (Python interpreter)
- `GCC_MAJOR_VER=11` (C++ compiler)
- `CK_QAIC_PERCENTILE_CALIBRATION=no` (see below)
- `CK_QAIC_PCV=9985` (PCV stands for percentile calibration value, see below)
- `CK_VER=2.6.1` ([MLCommons Collective Knowledge](https://github.com/mlcommons/ck))
- `DEBUG_BUILD=no` (DEBUG_BUILD=yes builds a larger image with support for model compilation)

Typically, only `SDK_DIR` and `SDK_VER` need to be customized.

### Build commands

#### Default PCV (~1 hour)
```
SDK_DIR=$WORKSPACE/sdks SDK_VER=1.6.80 $(ck find repo:ck-qaic)/docker/build.sh bert
```

##### Check
```
docker image prune && docker image ls | head -n 6
```
<details><pre>
REPOSITORY                          TAG            IMAGE ID       CREATED          SIZE
krai/mlperf.bert.centos7            1.6.80         5b6603e9533a   2 minutes ago    6.14GB
krai/ck.bert.centos7                latest         dc63f7469ed0   16 minutes ago   11GB
krai/ck.common.centos7              latest         1df24def6e4b   33 minutes ago   2.43GB
krai/centos7                        latest         b136531dce5d   37 minutes ago   1GB
krai/qaic.centos7                   1.6.80         6fff1756e9f4   45 minutes ago   2.22GB
</pre>

The images tagged with `1.6.80` are SDK-dependent, and need to be rebuilt with newer SDKs.
The images tagged with `latest` are SDK-independent, and can be reused with newer SDKs.
</details>

#### Given PCV (~1 hour)
```
SDK_DIR=$WORKSPACE/sdks SDK_VER=1.6.80 CK_QAIC_PCV=9985 $(ck find repo:ck-qaic)/docker/build.sh bert
```
Note that `CK_QAIC_PCV` cannot be specified together with `CK_QAIC_PERCENTILE_CALIBRATION=yes` (`no` by default).

#### Best PCV (~2 hours)
```
SDK_DIR=$WORKSPACE/sdks SDK_VER=1.6.80 CK_QAIC_PERCENTILE_CALIBRATION=yes $(ck find repo:ck-qaic)/docker/build.sh bert
```
Note that `CK_QAIC_PERCENTILE_CALIBRATION=yes` cannot be specified together with `CK_QAIC_PCV`.

##### Check
```
docker image prune && docker image ls | head -n 9
```
<details><pre>
REPOSITORY                          TAG            IMAGE ID       CREATED             SIZE
krai/mlperf.bert.centos7            1.6.80         074289ee7fac   4 minutes ago       6.36GB
krai/mlperf.bert.centos7            1.6.80_PC      c4bc6ea9f83d   6 minutes ago       14.2GB
krai/mlperf.bert.centos7            1.6.80_DEBUG   f5ea6d335c9f   About an hour ago   13.6GB
<none>                              <none>         5b6603e9533a   3 hours ago         6.14GB
krai/ck.bert.centos7                latest         dc63f7469ed0   3 hours ago         11GB
krai/ck.common.centos7              latest         1df24def6e4b   3 hours ago         2.43GB
krai/centos7                        latest         b136531dce5d   3 hours ago         1GB
krai/qaic.centos7                   1.6.80         6fff1756e9f4   4 hours ago         2.22GB
</pre>

Note the new auxiliary images tagged with `1.6.80_PC` and `1.6.80_DEBUG`, which can be removed. The image with id `5b6603e9533a` is the previously built (and now untagged) `krai/mlperf.bert.centos7:1.6.80 with the default PCV.
</details>


## Launch a reusable Docker container

```
export SDK_VER=1.6.80 && CONTAINER_ID=$(ck run cmdgen:benchmark.packed-bert.qaic-loadgen \
--docker=container_only --out=none --sdk=$SDK_VER --model_name=bert --experiment_dir)
```
#### Test
```
docker container ps
```
<details><pre>
CONTAINER ID   IMAGE                             COMMAND               CREATED         STATUS         PORTS     NAMES
d859c6f4dfd6   krai/mlperf.bert.centos7:1.6.80   "/bin/bash -c bash"   7 seconds ago   Up 6 seconds             gracious_goldstine
</pre></details>

## Measure accuracy

BERT is two-benchmarks-in-one: BERT-99.9 must reach at least 99.9% of the reference accuracy (f1 score of 90.875%), i.e. 90.784%; BERT-99 must reach at least 99.0% of the reference accuracy, i.e. 89.966%. Achieving the latter can be tricky as the best PCV (percentile calibration value) may depend on the host architecture, SDK version, etc.

### BERT-99.9
```
export SDK_VER=1.6.80 && ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--model=bert-99.9 --scenario=offline --mode=accuracy --dataset_size=10833 \
--sdk=$SDK_VER --container=$CONTAINER_ID --sut=g292_z43_q16
```
<details>
<pre>
{"exact_match": 83.68968779564806, <b>"f1": 90.87603921605954</b>}
Reading examples...
No cached features at '/home/krai/CK_TOOLS/dataset-squad-tokenized-converted-raw-width.384/bert_tokenized_squad_v1_1.pickle'... converting from examples...
Creating tokenizer...
Converting examples to features...
Caching features at '/home/krai/CK_TOOLS/dataset-squad-tokenized-converted-raw-width.384/bert_tokenized_squad_v1_1.pickle'...
Loading LoadGen logs...
Post-processing predictions...
Writing predictions to: predictions.json
Evaluating predictions...
real    2m22.933s
user    0m0.191s
sys     0m0.124s
</pre>
<b>NB:</b> Most of the time is spent on calculating the accuracy metric rather than on processing 10,833 samples.
</details>

#### Check
```
ck list $CK_EXPERIMENT_REPO:experiment:*
```
<details><pre>
mlperf-closed-g292_z43_q16-qaic-v1.6.80-aic100-qaic-v1.6.80-aic100-bert-<b>bert-99.9-offline-accuracy-dataset_size.10833</b>
<pre></details>

### BERT-99

```
export SDK_VER=1.6.80 && ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--model=bert-99 --mode=accuracy --scenario=offline --dataset_size=10833 \
--sdk=$SDK_VER --container=$CONTAINER_ID --sut=g292_z43_q16
```
<details>
- With the default PCV (98.85% of the reference):
<pre>{"exact_match": 82.10028382213812, <b>"f1": 89.83088437186652</b>}</pre>
- With the 99.85% PCV (99.10% of the reference): 
<pre>{"exact_match": 82.2421948912015, <b>"f1": 90.05632728113551}</b></pre>
- With the best PCV (99.30% of the reference):
<pre>{"exact_match": 82.83822138126774, <b>"f1": 90.24240186119648</b>}</pre>
</details>

## Measure performance

### Offline

When measuring the performance under the Offline scenario, the target QPS (queries per second) parameter should be specified as close to the actual system performance as possible to achieve the required minimum duration of 10 minutes.

```
export SDK_VER=1.6.80 && ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--model=bert-99 --mode=performance --scenario=offline \
--sdk=$SDK_VER --container=$CONTAINER_ID --sut=g292_z43_q16 --target_qps=11111
```
<details>
<pre>
================================================
MLPerf Results Summary
================================================
SUT name : QAIC_SUT
Scenario : Offline
Mode     : PerformanceOnly
<b>Samples per second: 11022.4</b>
<b>Result is : VALID</b>
  Min duration satisfied : Yes
  Min queries satisfied : Yes
</pre><pre>
================================================
Additional Stats
================================================
Min latency (ns)                : 13827778
Max latency (ns)                : 659318890980
Mean latency (ns)               : 329709531619
50.00 percentile latency (ns)   : 329746545192
90.00 percentile latency (ns)   : 593408489314
95.00 percentile latency (ns)   : 626361044806
97.00 percentile latency (ns)   : 639545767581
99.00 percentile latency (ns)   : 652727350675
99.90 percentile latency (ns)   : 658661794712
</pre><pre>
================================================
Test Parameters Used
================================================
samples_per_query : 7267260
target_qps : 11011
target_latency (ns): 0
max_async_queries : 1
min_duration (ms): 600000
max_duration (ms): 0
min_query_count : 1
max_query_count : 0
qsl_rng_seed : 1624344308455410291
sample_index_rng_seed : 517984244576520566
schedule_rng_seed : 10051496985653635065
accuracy_log_rng_seed : 0
accuracy_log_probability : 0
accuracy_log_sampling_target : 0
print_timestamps : 0
performance_issue_unique : 0
performance_issue_same : 0
performance_issue_same_index : 0
performance_sample_count : 10833
</pre><pre>
No warnings encountered during test.
</pre>
</details>

Setting the target QPS parameter to about 1/10th of the actual system performance reduces the execution time to about 1 minute, which is handy for quick test runs.

```
export SDK_VER=1.6.80 && ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--model=bert-99 --mode=performance --scenario=offline \
--sdk=$SDK_VER --container=$CONTAINER_ID --sut=g292_z43_q16 --target_qps=1111
```
<details>
<pre>
================================================
MLPerf Results Summary
================================================
SUT name : QAIC_SUT
Scenario : Offline
Mode     : PerformanceOnly
Samples per second: 11023.4
<b>Result is : INVALID</b>
<b>  Min duration satisfied : NO</b>
  Min queries satisfied : Yes
Recommendations:
<b> * Increase expected QPS so the loadgen pre-generates a larger (coalesced) query.</b>
</pre><pre>
================================================
Additional Stats
================================================
Min latency (ns)                : 13319750
Max latency (ns)                : 66518421631
Mean latency (ns)               : 33266286613
50.00 percentile latency (ns)   : 33264512160
90.00 percentile latency (ns)   : 59862782613
95.00 percentile latency (ns)   : 63192916020
97.00 percentile latency (ns)   : 64522849990
99.00 percentile latency (ns)   : 65849641866
99.90 percentile latency (ns)   : 66448261447
</pre><pre>
================================================
Test Parameters Used
================================================
samples_per_query : 733260
target_qps : 1111
target_latency (ns): 0
max_async_queries : 1
min_duration (ms): 600000
max_duration (ms): 0
min_query_count : 1
max_query_count : 0
qsl_rng_seed : 1624344308455410291
sample_index_rng_seed : 517984244576520566
schedule_rng_seed : 10051496985653635065
accuracy_log_rng_seed : 0
accuracy_log_probability : 0
accuracy_log_sampling_target : 0
print_timestamps : 0
performance_issue_unique : 0
performance_issue_same : 0
performance_issue_same_index : 0
performance_sample_count : 10833
</pre><pre>
No warnings encountered during test.
</pre>
</details>

### Server

When measuring the performance under the Server scenario, the target QPS is expected to be within 95% of that for the Offline scenario e.g.:
```
export SDK_VER=1.6.80 && ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--model=bert-99 --mode=performance --scenario=server \
--sdk=$SDK_VER --container=$CONTAINER_ID --sut=g292_z43_q16 --target_qps=10555
```

Unfortunately, for the Server scenario, reducing the target QPS also leads to decreasing the system load, so you cannot do that to reduce the number of queries for a test run. For that, use the `--query_count` parameter e.g.:
```
export SDK_VER=1.6.80 && ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--model=bert-99 --mode=performance --scenario=server \
--sdk=$SDK_VER --container=$CONTAINER_ID --sut=g292_z43_q16 --target_qps=10555 --query_count=40320
```
<details>
<pre>
================================================
MLPerf Results Summary
================================================
SUT name : QAIC_SUT
Scenario : Server
Mode     : PerformanceOnly
Scheduled samples per second : 10506.00
<b>Result is : INVALID</b>
  Performance constraints satisfied : Yes
<b>  Min duration satisfied : NO</b>
  Min queries satisfied : Yes
Recommendations:
<b> * Increase the target QPS so the loadgen pre-generates more queries.</b>
</pre><pre>
================================================
Additional Stats
================================================
Completed samples per second    : 10433.21
Min latency (ns)                : 8840838
Max latency (ns)                : 127487128
Mean latency (ns)               : 60321693
50.00 percentile latency (ns)   : 60803804
90.00 percentile latency (ns)   : 88844592
95.00 percentile latency (ns)   : 95615046
97.00 percentile latency (ns)   : 98577624
99.00 percentile latency (ns)   : 104054414
99.90 percentile latency (ns)   : 113836408
</pre><pre>
================================================
Test Parameters Used
================================================
samples_per_query : 1
target_qps : 10555
target_latency (ns): 130000000
max_async_queries : 0
min_duration (ms): 600000
max_duration (ms): 0
min_query_count : 40320
max_query_count : 40320
qsl_rng_seed : 1624344308455410291
sample_index_rng_seed : 517984244576520566
schedule_rng_seed : 10051496985653635065
accuracy_log_rng_seed : 0
accuracy_log_probability : 0
accuracy_log_sampling_target : 0
print_timestamps : 0
performance_issue_unique : 0
performance_issue_same : 0
performance_issue_same_index : 0
performance_sample_count : 10833
</pre><pre>
No warnings encountered during test.
2 ERRORS encountered. See detailed log.
</pre>
</details>

## Make a full submission run

```
export SDK_VER=1.6.80 && ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--model=bert-99 --sut=g292_z43_q16 --group.datacenter --group.closed \
--target_qps=11111 --server_target_qps=10777 --max_wait=10000 --override_batch_size=4096 \
--sdk=$SDK_VER --container=$CONTAINER_ID
```

## Miscellaneous useful commands

### Useful `ipmitool` commands

#### Read the fan speed

##### Gigabyte R282-Z93
```
sudo ipmitool sensor get BPB_FAN_1A
```
<details><pre>
Locating sensor record...
Sensor ID              : BPB_FAN_1A (0xa0)
 Entity ID             : 29.1
 Sensor Type (Threshold)  : Fan
<b> Sensor Reading        : 8100 (+/- 0) RPM</b>
 Status                : ok
 Lower Non-Recoverable : na
 Lower Critical        : 1200.000
 Lower Non-Critical    : 1500.000
 Upper Non-Critical    : na
 Upper Critical        : na
 Upper Non-Recoverable : na
 Positive Hysteresis   : Unspecified
 Negative Hysteresis   : 150.000
 Assertion Events      :
 Assertions Enabled    : lnc- lcr-
 Deassertions Enabled  : lnc- lcr-
</pre></details>

##### Gigabyte G292-Z43
```
sudo ipmitool sensor get SYS_FAN2
```
<details><pre>
Locating sensor record...
Sensor ID              : SYS_FAN2 (0xa3)
 Entity ID             : 29.4
 Sensor Type (Threshold)  : Fan
 <b>Sensor Reading        : 10800 (+/- 0) RPM</b>
 Status                : ok
 Lower Non-Recoverable : 0.000
 Lower Critical        : 1200.000
 Lower Non-Critical    : 1500.000
 Upper Non-Critical    : 38250.000
 Upper Critical        : 38250.000
 Upper Non-Recoverable : 38250.000
 Positive Hysteresis   : Unspecified
 Negative Hysteresis   : 150.000
 Assertion Events      :
 Assertions Enabled    : lnc- lnc+ lcr- lcr+ lnr- lnr+ unc- unc+ ucr- ucr+ unr- unr+
 Deassertions Enabled  : lnc- lnc+ lcr- lcr+ lnr- lnr+ unc- unc+ ucr- ucr+ unr- unr+
</pre></details>

#### Set the fan speed

##### Gigabyte R282-Z93, G292-Z43

Value | Speed, RPM
-|-
0     | 3,000
25    | 4,200
50    | 5,550
75    | 6,750
100   | 8,100
125   | 9,450
150   | 10,800
200   | 13,350
250   | 15,900

For example, to set the fan speed to 8,100 RPM, use <b>100</b>:

<pre>
sudo ipmitool raw 0x2e 0x10 0x0a 0x3c 0 64 1 <b>100</b> 0xFF
</pre>

### Useful `watch` commands

#### Device frequency
```
watch -n 1 "/opt/qti-aic/tools/qaic-util -q | grep NSP\ Fr | cut -c 15-"
```

#### Device power
```
watch -n 1 "sensors | grep qaic-pci -A7 | grep power1 | cut -c 10-"
```

#### Device temperature
```
watch -n 1 "sensors | grep qaic-pci -A7 | grep temp2 | cut -c 10-"
````

#### Active users
```
watch -n 10 "who -a | grep -v old | grep -v exit=0 | grep -v LOGIN | grep -v system | grep -v run-level"
```

#### Docker images
```
watch -n 60 "docker image ls | head -n 5"
```
