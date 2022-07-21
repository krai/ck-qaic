# Set up Edge appliances

We provide instructions to set up an Edge appliance similar to  Qualcomm Edge
AI Development Kit (AEDK), which we call "the device", for MLPerf Inference
benchmarking from scratch.

We assume that the user operates a Linux workstation (or a Windows laptop
under WSL), which we call "the host". We further assume that the host has
installed the Collective Knowledge framework (CK) and the QAIC Apps SDK
matching the QAIC Platform SDK to be installed on the device.

Instructions below alternate between running on the host (marked with `H`)
and on the device (marked with `D`). Instructions to be run as superuser are
additionally marked with `S`.

Some instructions are to be run only once (marked with `1`). Some instructions
are to be repeated as needed e.g. for new SDK versions (marked with `R`).

# A. Initial host setup

## `[H1]` Set Variables and Paths
Update device name, paths and variables in `config.sh`, then `source` it
```
source $(ck find repo:ck-qaic)/script/setup.aedk/config.sh
```

**NB:** The full installation can take more than 50G. If the space on the root
partition of the device is limited and you wish to use a different partition,
change the `DEVICE_BASE_DIR` in `config.sh`.

## `[H1]` Pull the `ck-qaic` repository
```
ck pull repo --url=https://github.com/krai/ck-qaic
```

# B. Initial device setup under the `root` user

## `[H1]` Copy the scripts to the device
Copy the scripts in this directory to a temporary directory on the device e.g.:
```
scp -P ${DEVICE_PORT} $(ck find repo:ck-qaic)/script/setup.aedk/*.sh ${DEVICE_IP}:/tmp
```

## `[H1]` Connect to the device as `root`
Connect to the device as `root` e.g.:
```
ssh -p ${DEVICE_PORT} root@${DEVICE_IP}
```

## `[D1S]` Run
Go to the temporary directory and run:
```
cd /tmp/ && \
source ./config.sh && \
./1.run_as_root.sh
```

## `[D1S]` Set user password
```
passwd ${DEVICE_USER}
```

# C. Initial device setup under the `krai` user

## `[H1]` Connect to the device as `krai`
Connect to the device as `krai` e.g.:
```
ssh -p ${DEVICE_PORT} krai@${DEVICE_IP}
```

## `[D1]` Update scripts permissions
```
cd /tmp && \
sudo chown krai ./2.run_as_krai.sh ./3.install_benchmark.sh ./run_common.sh && \
sudo chmod u+x ./2.run_as_krai.sh ./3.install_benchmark.sh ./run_common.sh
```

## `[D1]` Run:
```
cd /tmp/ && \
source ./config.sh && \
./2.run_as_krai.sh
```

# D. Set up Imagenet
Suppose the ImageNet validation dataset (50,000 images) is in an archive (6.4G) called
`dataset-imagenet-ilsvrc2012-val.tar` in the `${HOST_DATASETS_DIR}` on the host machine. Check the md5sum.

<details><pre>
&dollar; md5sum ${HOST_DATASETS_DIR}/dataset-imagenet-ilsvrc2012-val.tar
3f31a40f2bb902e28aa23aad0fc8e383  dataset-imagenet-ilsvrc2012-val.tar
</pre></details>

## `[H1]` Copy the ImageNet dataset from the host to the device
```
scp -P ${DEVICE_PORT} ${HOST_DATASETS_DIR}/dataset-imagenet-ilsvrc2012-val.tar root@${DEVICE_IP}:${DEVICE_DATASETS_DIR}
```

## `[D1]` Preprocess Imagenet on the device
```
cd /tmp/ && \
source ./config.sh && \
./3.install_benchmark.sh
```

# E. Set up QAIC SDKs
Obtain a pair of QAIC SDKs:
- Apps SDK to be used on the host for compilation (e.g. `qaic-apps-1.7.1.12.zip`).
- Platform SDK to be used on the device for execution (e.g. `qaic-platform-sdk-1.7.1.12.zip`).

These steps are to be repeated for each new SDK version (`SDK_VER` below).

## `[HSR]` Uninstall/Install the Apps SDK

Specify `SDK_DIR`, the path to a directory with one or more Apps SDK archives, and `SDK_VER`, the Apps SDK version.
The full path to the Apps SDK archive is formed as follows: `APPS_SDK=$SDK_DIR/qaic-apps-$SDK_VER.zip`.

```
SDK_DIR=/local/mnt/workspace/sdks SDK_VER=1.7.1.12 $(ck find ck-qaic:script:setup.aedk)/install_apps_sdk.sh
```

Alternatively, specify `APPS_SDK`, the full path to the Apps SDK archive.

<details><pre>
&dollar; grep build_id /opt/qti-aic/versions/apps.xml -B1
                &lsaquo;base_version&rsaquo;1.6&lsaquo;&sol;base_version&rsaquo;
                &lsaquo;build_id&rsaquo;80&lsaquo;&sol;build_id&rsaquo;
</pre></details>

## `[HR]` Copy the Platform SDK to the device

Go to the directory containing your Platform SDK archive e.g. `/local/mnt/workspace/sdks`
and copy it to the device e.g. with the `${DEVICE_IP}` address and `${DEVICE_PORT}` port:

```
export SDK_VER=1.7.1.12
scp -P ${DEVICE_PORT} qaic-platform-sdk-${SDK_VER}.zip ${DEVICE_USER}@${DEVICE_IP}:${DEVICE_BASE_DIR}/${DEVICE_USER}
```

## `[DSR]` Uninstall/Install the Platform SDK

Specify `SDK_DIR`, the path to a directory with one or more Platform SDK archives, and `SDK_VER`, the Platform SDK version.
The full path to the Platform SDK archive is formed as follows: `PLATFORM_SDK=$SDK_DIR/qaic-platform-sdk-$SDK_VER.zip`.

```
SDK_DIR=${DEVICE_BASE_DIR}/${DEVICE_USER} SDK_VER=1.7.1.12 bash $(ck find ck-qaic:script:setup.aedk)/install_platform_sdk.sh
```

Alternatively, specify `PLATFORM_SDK`, the full path to the Platform SDK archive.

<details><pre>
LRT QC_IMAGE_VERSION: LRT.AIC.6.7.1.6.52
LRT IMAGE_VARIANT: LRT.AIC.REL
Number of devices: 1
QID 0
        Status:Ready
        PCI Address:0002:01:00.0
        PCI Info:Unassigned class [ff00] Qualcomm Device a100
        HW Version:0.2.0.0
        HW Serial:0x2b36e75d
        FW Version:1.6.36
        FW QC_IMAGE_VERSION:QSM.AIC.1.6.36
        FW OEM_IMAGE_VERSION:
        FW IMAGE_VARIANT:AIC100.REL
        NSP Version:1.6.18
        NSP QC_IMAGE_VERSION:NSP.AIC.1.6.18
        NSP OEM_IMAGE_VERSION:
        NSP IMAGE_VARIANT:aic100.nsp.prodQ
        Compiler Version:0
        Dram Total:8116 MB
        Dram Free:8116 MB
        Dram Fragmentation:0.00%
        Vc Total:16
        Vc Free:16
        Nsp Total:8
        Nsp Free:8
        Peak Dram Bw:0.0
        Peak Sram Bw:0.0
        Peak PcieBw:0.0
        MCID Total:3072
        MCID Free:3072
        Semaphore Total:32
        Semaphore Free:32
        Constants Loaded:0
        Constants In-Use:0
        Networks Loaded:0
        Networks Active:0
        NSP Frequency(Mhz):595
        DDR Frequency(Mhz):2133
        COMPNOC Frequency(Mhz):1450
        MEMNOC Frequency(Mhz):1000
        SYSNOC Frequency(Mhz):667
        Metadata Version:0.10
        NNC Command Protocol Version:8.1
        SBL Image:SBL.AIC.1.6.21
        PVS Image Version:24
        NSP Defective PG Mask: 0xAAAA
        Board serial:
</pre></details>

## `[HR]` Compile the workloads on the host and copy to the device

The easiest way to install the workloads to the device is to use Docker images [prebuilt](https://github.com/krai/ck-qaic/blob/main/script/setup.docker/README.md) on the host e.g.:

```base
cd $(ck find ck-qaic:script:setup.aedk)
DEVICE_IP=192.168.0.12 DEVICE_PORT=1234 DEVICE_PASSWORD=12345678 ./install_to_aedk.sh
```

If you do not wish to use Docker images, you can follow common [instructions](https://github.com/krai/ck-qaic/blob/main/program/README.md), and then instructions for individual workloads:

1. [Image Classfication](https://github.com/krai/ck-qaic/blob/main/program/image-classification-qaic-loadgen/README.md) (ResNet50)
1. [Object Detection](https://github.com/krai/ck-qaic/blob/main/program/object-detection-qaic-loadgen/README.md) (SSD-MobileNet, SSD-ResNet34)
1. [Language Processing](https://github.com/krai/ck-qaic/blob/main/program/packed-bert-qaic-loadgen/README.md) (BERT-99)

## Arguments

### `SDK_VER`

The SDK version. Must be set.

### `DEVICE_IP`

The IP address or hostname of the device. Must be set.

### `DEVICE_PORT`

The SSH port on the device. Default: `22`.

### `DEVICE_PASSWORD`

The password on the device. Must be set. The password is not stored.

### `DEVICE_BASE_DIR`

The root of the user directories on the device. Default: `data`.

### `DEVICE_USER`

The username on the device. Default: `krai`.

### `DEVICE_TYPE`

The type of the device.  Default: `aedk_15w` (e.g. for Foxconn Gloria and Alibaba Haishen).

### `WORKLOADS`

Default: `WORKLOADS="resnet50,bert"`. A comma-separated list of workloads to compile and install.

### `UPDATE_CK_QAIC`

Default: `UPDATE_CK_QAIC=yes`. If `UPDATE_CK_QAIC=no`, do not update the `ck-qaic` repo.

### `DRY_RUN`

Default: `DRY_RUN=no`. If `DRY_RUN=yes`, only print commands but do not execute them.

### `DRY_COMPILE`

Default: `DRY_COMPILE=no`. If `DRY_COMPILE=yes`, only print compilation commands. This requires operating with workload binaries baked into the Docker image. See `DOCKER_DEVICE_TYPE`.

### `DRY_INSTALL`

Default: `DRY_INSTALL=no`. If `DRY_INSTALL=yes`, only print installation commands.

### `DOCKER`

Default: `yes`. Whether to use Docker images to run compile and install workloads.

### `DOCKER_OS`

Default: `DOCKER_OS=ubuntu`. If `DOCKER_OS=ubuntu`, assume Ubuntu 20.04 based images have been created. If `DOCKER_OS=centos`, assume CentOS 7 based images have been created.

### `DOCKER_DEVICE_TYPE`

Default: `DOCKER_DEVICE_TYPE=pcie.16nsp`. See `DRY_COMPILE`.

Use `DOCKER_DEVICE_TYPE=pcie.14nsp` if images have been compiled with the `COMPILE_PRO=no COMPILE_STD=yes` flags.
