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
## Docker setup

Go to the following directory in `ck-qaic` as base:
```
cd script/setup.docker
```

Define the workspace directory:
```
export WORKSPACE_DIR=/local/mnt/workspace
```
**NB:** Workspace directory should contain a subdirectory for SDKs: `$WORKSPACE_DIR/sdks` where need to be copied archives of Apps and Platform SDKs (e.g. `qaic-apps-1.8.3.7.zip` and `qaic-platform-sdk-x86_64-ubuntu-1.8.3.7.zip`). A system folder `docker` (`$WORKSPACE_DIR/docker`) and the experimental results folder will be also placed there during the installation.

### Host OS dependent


#### Ubuntu host (supported: Ubuntu 20.04)

```
WORKSPACE_DIR=$WORKSPACE_DIR bash setup_ubuntu.sh
```

### Host OS independent

#### Set up Collective Knowledge environment
```
WORKSPACE_DIR=$WORKSPACE_DIR bash setup_ck.sh
```

## Create Docker images

### Build blank image for ImageNet

```
cd $(ck find repo:ck-qaic)/docker/imagenet
DATASETS_DIR=no ./build.sh
```

### Target OS dependent, SDK dependent

**NB:** In principle, you can use any combination of the host OS and target OS e.g. Ubuntu host and CentOS target.  For simplicity, however, we recommend to use the same OS to satisfy MLPerf requirements.

**NB:** Make sure to have copied the required SDKs
to `$WORKSPACE_DIR/sdks`.

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

### `r282_z93_q3_std`
```
cd $(ck find ck-qaic:script:run)
WORKLOADS=resnet50,retinanet SDK_VER=1.8.3.7 DOCKER=yes SUT=r282_z93_q3_std DEFS_DIR=$CK_REPOS/ck-qaic/script/defs ./run_datacenter.sh
```

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
ck list $CK_EXPERIMENT_REPO:experiment:*r282_z93_q3_std* | sort
```
<details><pre>
eselezne@aus655-pci-bowie:/local/mnt/workspace/eselezne/CK-REPOS/mlperf_v3.0.aus655-pci-bowie.eselezne/experiment$ ck list mlperf_v3.0.aus655-pci-bowie.eselezne:experiment:*r282_z93_q3_std* | sort
mlperf_v3.0-closed-r282_z93_q3_std-qaic-v1.8.3.7-aic100-resnet50-offline-accuracy-dataset_size.50000-preprocessed_using.opencv
mlperf_v3.0-closed-r282_z93_q3_std-qaic-v1.8.3.7-aic100-resnet50-offline-performance-target_qps.60000-fan_raw.250-vc.17
mlperf_v3.0-closed-r282_z93_q3_std-qaic-v1.8.3.7-aic100-resnet50-server-accuracy-dataset_size.50000-preprocessed_using.opencv
mlperf_v3.0-closed-r282_z93_q3_std-qaic-v1.8.3.7-aic100-resnet50-server-performance-target_qps.58000-fan_raw.250-vc.17
mlperf_v3.0-closed-r282_z93_q3_std-qaic-v1.8.3.7-aic100-resnet50-server-performance-target_qps.59000-fan_raw.250-vc.17
mlperf_v3.0-closed-r282_z93_q3_std-qaic-v1.8.3.7-aic100-retinanet-offline-accuracy-dataset_size.24781-preprocessed_using.opencv
mlperf_v3.0-closed-r282_z93_q3_std-qaic-v1.8.3.7-aic100-retinanet-offline-performance-target_qps.840-fan_raw.250-vc.17
mlperf_v3.0-closed-r282_z93_q3_std-qaic-v1.8.3.7-aic100-retinanet-server-accuracy-dataset_size.24781-preprocessed_using.opencv
mlperf_v3.0-closed-r282_z93_q3_std-qaic-v1.8.3.7-aic100-retinanet-server-performance-target_qps.780-fan_raw.250-vc.17
</pre></details>

### Grep results in the experiment directory
```
cd $CK_EXPERIMENT_DIR
grep '"INVALID"' *r282_z93_q3_std*/*.0001.json
```
<details><pre>
eselezne@aus655-pci-bowie:/local/mnt/workspace/eselezne/CK-REPOS/mlperf_v3.0.aus655-pci-bowie.eselezne/experiment$ grep '"INVALID"' *r282_z93_q3_std*/*.0001.json
mlperf_v3.0-closed-r282_z93_q3_std-qaic-v1.8.3.7-aic100-resnet50-server-performance-target_qps.59000-fan_raw.250-vc.17/ckp-378d944b268d1eb8.0001.json:          "Result is": "INVALID",
</pre></details>

```
grep '"Samples per second"' *r282_z93_q3_std*/*.0001.json
```
<details><pre>
eselezne@aus655-pci-bowie:/local/mnt/workspace/eselezne/CK-REPOS/mlperf_v3.0.aus655-pci-bowie.eselezne/experiment$ grep '"Samples per second"' *r282_z93_q3_std*/*.0001.json
mlperf_v3.0-closed-r282_z93_q3_std-qaic-v1.8.3.7-aic100-resnet50-offline-performance-target_qps.60000-fan_raw.250-vc.17/ckp-965f136a44004048.0001.json:          "Samples per second": "61169.7",
mlperf_v3.0-closed-r282_z93_q3_std-qaic-v1.8.3.7-aic100-retinanet-offline-performance-target_qps.840-fan_raw.250-vc.17/ckp-01acb24a054d468d.0001.json:          "Samples per second": "830.597",
</pre></details>

```
grep '"Scheduled samples per second"' *r282_z93_q3_std*/*.0001.json
```
<details><pre>
eselezne@aus655-pci-bowie:/local/mnt/workspace/eselezne/CK-REPOS/mlperf_v3.0.aus655-pci-bowie.eselezne/experiment$ grep '"Scheduled samples per second"' *r282_z93_q3_std*/*.0001.json
mlperf_v3.0-closed-r282_z93_q3_std-qaic-v1.8.3.7-aic100-resnet50-server-performance-target_qps.58000-fan_raw.250-vc.17/ckp-c7536bc4cad921b7.0001.json:          "Scheduled samples per second": "57999.05",
mlperf_v3.0-closed-r282_z93_q3_std-qaic-v1.8.3.7-aic100-resnet50-server-performance-target_qps.59000-fan_raw.250-vc.17/ckp-378d944b268d1eb8.0001.json:          "Scheduled samples per second": "58998.49",
mlperf_v3.0-closed-r282_z93_q3_std-qaic-v1.8.3.7-aic100-retinanet-server-performance-target_qps.780-fan_raw.250-vc.17/ckp-049968dcf6bcb2a8.0001.json:          "Scheduled samples per second": "779.07",
</pre></details>

```
grep '"mAP"' *r282_z93_q3_std*/*.0001.json
```
<details><pre>
eselezne@aus655-pci-bowie:/local/mnt/workspace/eselezne/CK-REPOS/mlperf_v3.0.aus655-pci-bowie.eselezne/experiment$ grep '"mAP"' *r282_z93_q3_std*/*.0001.json
mlperf_v3.0-closed-r282_z93_q3_std-qaic-v1.8.3.7-aic100-retinanet-offline-accuracy-dataset_size.24781-preprocessed_using.opencv/ckp-44b3818a4e497d41.0001.json:        "mAP": 37.239,
mlperf_v3.0-closed-r282_z93_q3_std-qaic-v1.8.3.7-aic100-retinanet-server-accuracy-dataset_size.24781-preprocessed_using.opencv/ckp-6bb5830c547cde64.0001.json:        "mAP": 37.239,
</pre></details>

```
grep '"accuracy"' *r282_z93_q3_std*/*.0001.json
```
<details><pre>
eselezne@aus655-pci-bowie:/local/mnt/workspace/eselezne/CK-REPOS/mlperf_v3.0.aus655-pci-bowie.eselezne/experiment$ grep '"accuracy"' *r282_z93_q3_std*/*.0001.json
mlperf_v3.0-closed-r282_z93_q3_std-qaic-v1.8.3.7-aic100-resnet50-offline-accuracy-dataset_size.50000-preprocessed_using.opencv/ckp-54b6af4feb96cee3.0001.json:        "accuracy": 75.0,
mlperf_v3.0-closed-r282_z93_q3_std-qaic-v1.8.3.7-aic100-resnet50-offline-accuracy-dataset_size.50000-preprocessed_using.opencv/ckp-54b6af4feb96cee3.0001.json:          "accuracy": [
mlperf_v3.0-closed-r282_z93_q3_std-qaic-v1.8.3.7-aic100-resnet50-offline-performance-target_qps.60000-fan_raw.250-vc.17/ckp-965f136a44004048.0001.json:          "accuracy": [],
mlperf_v3.0-closed-r282_z93_q3_std-qaic-v1.8.3.7-aic100-resnet50-server-accuracy-dataset_size.50000-preprocessed_using.opencv/ckp-6487ac8f429475c8.0001.json:        "accuracy": 75.0,
mlperf_v3.0-closed-r282_z93_q3_std-qaic-v1.8.3.7-aic100-resnet50-server-accuracy-dataset_size.50000-preprocessed_using.opencv/ckp-6487ac8f429475c8.0001.json:          "accuracy": [
mlperf_v3.0-closed-r282_z93_q3_std-qaic-v1.8.3.7-aic100-resnet50-server-performance-target_qps.58000-fan_raw.250-vc.17/ckp-c7536bc4cad921b7.0001.json:          "accuracy": [],
mlperf_v3.0-closed-r282_z93_q3_std-qaic-v1.8.3.7-aic100-resnet50-server-performance-target_qps.59000-fan_raw.250-vc.17/ckp-378d944b268d1eb8.0001.json:          "accuracy": [],
mlperf_v3.0-closed-r282_z93_q3_std-qaic-v1.8.3.7-aic100-retinanet-offline-accuracy-dataset_size.24781-preprocessed_using.opencv/ckp-44b3818a4e497d41.0001.json:          "accuracy": [
mlperf_v3.0-closed-r282_z93_q3_std-qaic-v1.8.3.7-aic100-retinanet-offline-performance-target_qps.840-fan_raw.250-vc.17/ckp-01acb24a054d468d.0001.json:          "accuracy": [],
mlperf_v3.0-closed-r282_z93_q3_std-qaic-v1.8.3.7-aic100-retinanet-server-accuracy-dataset_size.24781-preprocessed_using.opencv/ckp-6bb5830c547cde64.0001.json:          "accuracy": [
mlperf_v3.0-closed-r282_z93_q3_std-qaic-v1.8.3.7-aic100-retinanet-server-performance-target_qps.780-fan_raw.250-vc.17/ckp-049968dcf6bcb2a8.0001.json:          "accuracy": [],
</pre></details>





