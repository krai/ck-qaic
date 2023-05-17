## Qualcomm Cloud AI - MLPerf Inference v3.0 - GIGABYTE R282-Z93-Q5/8-Standard  

## General setup

Clone `ck-qaic` repository:
```
git clone https://github.com/krai/ck-qaic
```
Go to `ck-qaic` directory and switch to the branch `r282_z93_q5_8_std`:
```
cd ck-qaic
git checkout r282_z93_q5_8_std
```
Add GitHub PAT to `~/.bashrc` and init it:
```
echo "export CK_QAIC_PAT=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" >> ~/.bashrc

source ~/.bashrc
```

## Docker setup

Go to the following directory in `ck-qaic` as base:
```
cd script/setup.docker
```

Define the workspace directory, e.g. `/home`
```
export WORKSPACE_DIR=/home
```

### Host OS dependent


#### Ubuntu host (supported: Ubuntu 20.04)

```
WORKSPACE_DIR=$WORKSPACE_DIR bash setup_ubuntu.sh
```

#### CentOS host (supported: CentOS 7)
```
WORKSPACE_DIR=$WORKSPACE_DIR bash setup_centos.sh
```

**NB:** Log out and log back in for the necessary group permissions to take effect.

### Host OS independent

#### Set up Collective Knowledge environment
```
WORKSPACE_DIR=$WORKSPACE_DIR bash setup_ck.sh
```

## Create Docker images

### Build blank image for ImageNet

```
cd $(ck find repo:ck-qaic)/docker/imagenet
WORKSPACE_DIR=$WORKSPACE_DIR DATASETS_DIR=no CK_QAIC_CHECKOUT=r282_z93_q5_8_std ./build.sh
```

### Target OS dependent, SDK dependent

**NB:** In principle, you can use any combination of the host OS and target OS e.g. Ubuntu host and CentOS target.  For simplicity, however, we recommend to use the same OS to satisfy MLPerf requirements.

**NB:** Make sure to have copied the required SDKs
to `$WORKSPACE_DIR/sdks`, respectively.

```
cd $(ck find repo:ck-qaic)/script/setup.docker
WORKSPACE_DIR=$WORKSPACE_DIR CK_QAIC_CHECKOUT=r282_z93_q5_8_std bash setup_images.sh
```

## Test Docker Images

```
cd $(ck find ck-qaic:script:run)
QUICK_RUN=yes WORKLOADS=resnet50,retinanet SDK_VER=1.8.3.7 DOCKER=yes SUT=r282_z93_q5_std ./run_datacenter.sh
```

## Benchmarking

### `r282_z93_q5_std`
```
cd $(ck find ck-qaic:script:run)
WORKLOADS=resnet50,retinanet SDK_VER=1.8.3.7 DOCKER=yes SUT=r282_z93_q5_std DEFS_DIR=$CK_REPOS/ck-qaic/script/defs ./run_datacenter.sh
```

### `r282_z93_q8_std`
```
cd $(ck find ck-qaic:script:run)
WORKLOADS=resnet50,retinanet SDK_VER=1.8.3.7 DOCKER=yes SUT=r282_z93_q8_std DEFS_DIR=$CK_REPOS/ck-qaic/script/defs ./run_datacenter.sh
```

## Browsing results

### List experiments
```
ck list mlperf_v3.0.$(hostname).$USER:experiment:*retinanet* | sort
```
<details><pre>
mlperf_v3.0-closed-r282_z93_q5_std-qaic-v1.8.3.7-aic100-retinanet-offline-accuracy-dataset_size.24781-preprocessed_using.opencv
mlperf_v3.0-closed-r282_z93_q5_std-qaic-v1.8.3.7-aic100-retinanet-offline-performance-target_qps.1400-fan_raw.250-vc.17
mlperf_v3.0-closed-r282_z93_q5_std-qaic-v1.8.3.7-aic100-retinanet-server-accuracy-dataset_size.24781-preprocessed_using.opencv
mlperf_v3.0-closed-r282_z93_q5_std-qaic-v1.8.3.7-aic100-retinanet-server-performance-target_qps.1330-fan_raw.250-vc.17
</pre></details>

### Grep results in the experiment directory
```
cd $CK_REPOS/mlperf_v3.0.$(hostname).$USER/experiment
grep INVALID */*.0001.json
grep Samples per second */*.0001.json
grep Scheduled samples per second */*.0001.json
grep mAP *retinanet*/*.0001.json
grep '"accuracy"' *resnet50*/*.0001.json
```





