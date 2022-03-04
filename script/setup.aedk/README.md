# Set up Edge AI Development Kit (AEDK)

We provide instructions to set up a Qualcomm Edge AI Development Kit (AEDK),
which we call "the device", for MLPerf Inference benchmarking from scratch.
We assume that the device has a recent firmware ("meta") installed e.g. `00064`.

We also assume that the user operates a Linux workstation (or a Windows laptop
under WSL), which we call "the host". We further assume that the host has
installed the Collective Knowledge framework (CK) and the QAIC Apps SDK
matching the QAIC Platform SDK to be installed on the device.

Instructions below alternate between running on the host (marked with `H`)
and on the device (marked with `D`). Instructions to be run as superuser are
additionally marked with `S`.

Some instructions are to be run only once (marked with `1`). Some instructions
are to be repeated as needed e.g. for new SDK versions (marked with `R`).

# `[H1]` Initial host setup

## `[H1]` Pull the `ck-qaic` repository
```
ck pull repo --url=https://github.com/krai/ck-qaic
```

# `[D1]` Initial device setup

## `[H1]` Copy the scripts to the device

Copy the numbered scripts in this directory to a temporary directory on the device e.g.:
```
scp $(ck find repo:ck-qaic)/script/setup.aedk/?.*.sh aedk1:/tmp
```

## `[D1S]` Run under the `root` user

Connect to the device as `root` e.g.:
```
ssh root@aedk1
```

Go to the temporary directory and run:
```
./1.run_as_root.sh
```

If there is not enough space on the root partition and we want krai user to use a different partition say /data for benchmark data (can be more than 50GB), you can do
```
usermod -d /data/krai krai
```

## `[D1]` Run under the `krai` user

Connect to the device as `krai` e.g.:
```
ssh krai@aedk1
```

Go to the temporary directory and run:
```
sudo chown krai ./2.run_as_krai.sh
sudo chmod u+x ./2.run_as_krai.sh
./2.run_as_krai.sh
```

# `[H1]` Set up ImageNet

## `[H1]` Obtain the ImageNet dataset

Suppose the ImageNet validation dataset (50,000 images) is in an archive called
`dataset-imagenet-ilsvrc2012-val.tar` (6.4G).

<details><pre>
&dollar; md5sum dataset-imagenet-ilsvrc2012-val.tar
3f31a40f2bb902e28aa23aad0fc8e383  dataset-imagenet-ilsvrc2012-val.tar
</pre></details>

Extract it under e.g. `$HOME` or `/datasets`:
```
tar xvf dataset-imagenet-ilsvrc2012-val.tar -C $HOME
```

## `[H1]` Detect the ImageNet dataset
```
echo "full" | ck detect soft:dataset.imagenet.val --extra_tags=ilsvrc2012,full \
--full_path=$HOME/dataset-imagenet-ilsvrc2012-val/ILSVRC2012_val_00000001.JPEG
```

## `[H1]` Copy the ImageNet dataset to the device
```
scp dataset-imagenet-ilsvrc2012-val.tar aedk1:/home/krai
```

# `[R]` Set up QAIC SDKs

Obtain a pair of QAIC SDKs:
- Apps SDK to be used on the host for compilation (e.g. `qaic-apps-1.6.80.zip`).
- Platform SDK to be used on the device for execution (e.g. `qaic-platform-sdk-1.6.80.zip`).

These steps are to be repeated for each new SDK version (`SDK_VER` below).

## `[HSR]` Uninstall/Install the Apps SDK

Provide arguments for the the path to directory containing your Apps SDK archive `SDK_DIR` and the SDK version `SDK_VER` or the full path to the SDK archive `APPS_SDK`
Default: 
`SDK_DIR=/local/mnt/workspace/sdks` 
`SDK_VER=1.6.80` 
`APPS_SDK=$SDK_DIR/qaic-apps-$SDK_VER.zip`

```
SDK_DIR=/local/mnt/workspace/sdks SDK_VER=1.6.80 $(ck find ck-qaic:script:setup.aedk)/install_sdk_apps.sh
```

<details><pre>
&dollar; grep build_id /opt/qti-aic/versions/apps.xml -B1
                &lsaquo;base_version&rsaquo;1.6&lsaquo;&sol;base_version&rsaquo;
                &lsaquo;build_id&rsaquo;80&lsaquo;&sol;build_id&rsaquo;
</pre></details>

## `[HR]` Copy the Platform SDK to the device

Go to the directory containing your Platform SDK archive e.g. `/data/qaic`.

```
export SDK_VER=1.6.80
scp qaic-platform-sdk-$SDK_VER.zip aedk1:/home/krai
```

## `[DSR]` Uninstall/Install the Platform SDK

Provide arguments for the the path to directory containing your Platform SDK archive `SDK_DIR` and the SDK version `SDK_VER` or the full path to the SDK archive `PLATFORM_SDK`
Default:
`SDK_DIR=/home/krai` 
`SDK_VER=1.6.80`
`PLATFORM_SDK=$SDK_DIR/qaic-platform-sdk-$SDK_VER.zip`

```
SDK_DIR=/home/krai SDK_VER=1.6.80 $(ck find ck-qaic:script:setup.aedk)/install_sdk_platform.sh
```

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

## `[HR]` Compile the benchmarks on the host and copy to the device

### Common benchmark setup

Follow the instructions [here](https://github.com/krai/ck-qaic/blob/main/program/README.md).

### Individual benchmark setup

1. [Image Classfication](https://github.com/krai/ck-qaic/blob/main/program/image-classification-qaic-loadgen/README.md) (ResNet50)
1. [Object Detection](https://github.com/krai/ck-qaic/blob/main/program/object-detection-qaic-loadgen/README.md) (SSD-MobileNet, SSD-ResNet34)
1. [Language Processing](https://github.com/krai/ck-qaic/blob/main/program/packed-bert-qaic-loadgen/README.md) (BERT-99)

### Copy the benchmarks to the device

**Hint:** To avoid entering the device password every time, generate an SSH key on the host:

```
ssh-keygen -t rsa
```

and install it on the device e.g.:

```
ssh-copy-id krai@aedk1
```

Compile and install the benchmarks e.g. to a `aedk_15w` device:
```
SUT=aedk_15w USER=krai IPS=aedk1 PORTS=22 $(ck find ck-qaic:script:setup.aedk)/install_to_aedk.sh
```
