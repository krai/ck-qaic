# Mlcommons 1.1 Submission Values

| Benchmark | SDK | Offline Performance | Offline Power | Server Performance | Server Power |
| --------- | --- | ------------------- | ------------- | ------------------ | ------------ |
| Bert-99 | 1.5.9 | 5202.88 | 776.3 | 4,902.82 | 765.17 |
| Bert-99.9 | 1.5.9 | 2,664.14 | 841.44 | 2250.17 | 763.92 |

## Start the power server (Should be already started)

``` 
ssh scourge
``` 
``` 
sudo su
nohup /usr/bin/python3.7 /local/mnt/workspace/mlcommons/power-dev/ptd_client_server/server.py \
-c /local/mnt/workspace/mlcommons/power-dev/ptd_client_server/server.pr009.conf &
```

## Install python3.8 (Should be already installed)
```
sudo su
export PYTHON_VERSION=3.8.12
cd /usr/src \
&& wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz \
&& tar xzf Python-${PYTHON_VERSION}.tgz \
&& rm -f Python-${PYTHON_VERSION}.tgz \
&& cd /usr/src/Python-${PYTHON_VERSION} \
&& ./configure --enable-optimizations --enable-shared --with-ssl && make -j 32 altinstall \
&& rm -rf /usr/src/Python-${PYTHON_VERSION}*
```
```
python3.8 --version
```
`Python 3.8.12`

## Account Setup

```
sudo useradd auditor
sudo passwd auditor
sudo usermod -aG qaic,root,wheel,docker auditor
sudo mkdir /local/mnt/workspace/auditor
sudo chown auditor:qaic /local/mnt/workspace/auditor
ssh auditor@localhost
```

## Recommended user setup

### Set up CK

```
python3.8 -m pip install ck==1.55.5 --user
python3.8 -m pip install pandas --user
python3.8 -m pip install tabulate --user
python3.8 -m pip install tensorflow --user
python3.8 -m pip install transformers --user
```

### Set up CK paths

Place the following into your `~/.bashrc`:

```
export PATH=$HOME/.local/bin:$PATH
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib
export CK_PYTHON=`which python3.8`
export CK_REPOS=/local/mnt/workspace/$USER/CK_REPOS
export CK_TOOLS=/local/mnt/workspace/$USER/CK_TOOLS
export CK_EXPERIMENTS=$CK_REPOS/mlperf.$(hostname)/experiment
export POWER_pr009="--power=yes --power_server_ip=10.222.154.58 --power_server_port=4959"
```

Init it:

```
source ~/.bashrc
```

### Create a repository for experimental data

```
ck add repo:mlperf.$(hostname) --quiet && \
ck add mlperf.$(hostname):experiment:dummy --common_func && \
ck rm  mlperf.$(hostname):experiment:dummy --force
```

Experiments will land into this repository as if by magic!

```
ck list repo:mlperf.*
```
```
mlperf.aus655-pci-bowie
```

### Make the repository group-writable

All files under `$CK_EXPERIMENTS` must be group-writable:

```
chgrp qaic $CK_EXPERIMENTS -R && chmod g+ws $CK_EXPERIMENTS -R
```


Pull the required CK Repos

ck pull repo --url=https://github.com/krai/ck-qaic


### Check the QAIC SDK version

Confirm it is `1.5.9`

```
cat /opt/qti-aic/versions/platform.xml
```
```
<versions>
        <ci_build>
           <base_name>AIC</base_name>
           <base_version>1.5</base_version>
           <build_id>9</build_id>
        </ci_build>
        </versions>
```

### Check the fan speed

```
ipmitool -I lanplus -U admin -P password -H aus655-pci-bowie-bmc.qualcomm.com sensor get BPB_FAN_1A
```
<details>
  <summary>Click to see expected output!</summary>
        
```
Locating sensor record...
Sensor ID              : BPB_FAN_1A (0xa0)
 Entity ID             : 29.1
 Sensor Type (Threshold)  : Fan
 Sensor Reading        : 7950 (+/- 0) RPM
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
 ```

</details>
 
### Check the presence of eight 16-NSP cards
```
/opt/qti-aic/tools/qaic-util -q
```

<details>
  <summary>Click to see expected output!</summary>
        
```     
LRT QC_IMAGE_VERSION: LRT.AIC.5.2.1.5.6
LRT IMAGE_VARIANT: LRT.AIC.REL
Number of devices: 8
QID 0
        Status:Ready
        PCI Address:0000:01:00.0
        PCI Info:Processing accelerators Qualcomm Device a100
        HW Version:0.2.0.0
        HW Serial:0x64b5276b
        FW Version:1.5.6
        FW QC_IMAGE_VERSION:QSM.AIC.1.5.6
        FW OEM_IMAGE_VERSION:
        FW IMAGE_VARIANT:AIC100.REL
        NSP Version:1.5.2
        NSP QC_IMAGE_VERSION:NSP.AIC.1.5.2
        NSP OEM_IMAGE_VERSION:
        NSP IMAGE_VARIANT:aic100.nsp.prodQ
        Compiler Version:0
        Dram Total:32692 MB
        Dram Free:32692 MB
        Dram Fragmentation:0.00%
        Vc Total:16
        Vc Free:16
        Nsp Total:16
        Nsp Free:16
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
        NSP Frequency(Mhz):825
        DDR Frequency(Mhz):2133
        COMPNOC Frequency(Mhz):1450
        MEMNOC Frequency(Mhz):1000
        SYSNOC Frequency(Mhz):667
        Metadata Version:0.10
        NNC Command Protocol Version:8.0
        SBL Image:SBL.AIC.1.5.5
        PVS Image Version:18
        NSP Defective PG Mask: 0x0
        Board serial:PN471-12-343016
QID 1
        Status:Ready
        PCI Address:0000:81:00.0
        PCI Info:Processing accelerators Qualcomm Device a100
        HW Version:0.2.0.0
        HW Serial:0x24ef08a8
        FW Version:1.5.6
        FW QC_IMAGE_VERSION:QSM.AIC.1.5.6
        FW OEM_IMAGE_VERSION:
        FW IMAGE_VARIANT:AIC100.REL
        NSP Version:1.5.2
        NSP QC_IMAGE_VERSION:NSP.AIC.1.5.2
        NSP OEM_IMAGE_VERSION:
        NSP IMAGE_VARIANT:aic100.nsp.prodQ
        Compiler Version:0
        Dram Total:32692 MB
        Dram Free:32692 MB
        Dram Fragmentation:0.00%
        Vc Total:16
        Vc Free:16
        Nsp Total:16
        Nsp Free:16
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
        NSP Frequency(Mhz):825
        DDR Frequency(Mhz):2133
        COMPNOC Frequency(Mhz):1450
        MEMNOC Frequency(Mhz):1000
        SYSNOC Frequency(Mhz):667
        Metadata Version:0.10
        NNC Command Protocol Version:8.0
        SBL Image:SBL.AIC.1.5.5
        PVS Image Version:18
        NSP Defective PG Mask: 0x0
        Board serial:PN471-11-343015
QID 2
        Status:Ready
        PCI Address:0000:a1:00.0
        PCI Info:Processing accelerators Qualcomm Device a100
        HW Version:0.2.0.0
        HW Serial:0x47a633d6
        FW Version:1.5.6
        FW QC_IMAGE_VERSION:QSM.AIC.1.5.6
        FW OEM_IMAGE_VERSION:
        FW IMAGE_VARIANT:AIC100.REL
        NSP Version:1.5.2
        NSP QC_IMAGE_VERSION:NSP.AIC.1.5.2
        NSP OEM_IMAGE_VERSION:
        NSP IMAGE_VARIANT:aic100.nsp.prodQ
        Compiler Version:0
        Dram Total:32692 MB
        Dram Free:32692 MB
        Dram Fragmentation:0.00%
        Vc Total:16
        Vc Free:16
        Nsp Total:16
        Nsp Free:16
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
        NSP Frequency(Mhz):825
        DDR Frequency(Mhz):2133
        COMPNOC Frequency(Mhz):1450
        MEMNOC Frequency(Mhz):1000
        SYSNOC Frequency(Mhz):667
        Metadata Version:0.10
        NNC Command Protocol Version:8.0
        SBL Image:SBL.AIC.1.5.5
        PVS Image Version:18
        NSP Defective PG Mask: 0x0
        Board serial:PN471-11-343015
QID 3
        Status:Ready
        PCI Address:0000:a2:00.0
        PCI Info:Processing accelerators Qualcomm Device a100
        HW Version:0.2.0.0
        HW Serial:0x3c0c1ac3
        FW Version:1.5.6
        FW QC_IMAGE_VERSION:QSM.AIC.1.5.6
        FW OEM_IMAGE_VERSION:
        FW IMAGE_VARIANT:AIC100.REL
        NSP Version:1.5.2
        NSP QC_IMAGE_VERSION:NSP.AIC.1.5.2
        NSP OEM_IMAGE_VERSION:
        NSP IMAGE_VARIANT:aic100.nsp.prodQ
        Compiler Version:0
        Dram Total:32692 MB
        Dram Free:32692 MB
        Dram Fragmentation:0.00%
        Vc Total:16
        Vc Free:16
        Nsp Total:16
        Nsp Free:16
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
        NSP Frequency(Mhz):825
        DDR Frequency(Mhz):2133
        COMPNOC Frequency(Mhz):1450
        MEMNOC Frequency(Mhz):1000
        SYSNOC Frequency(Mhz):667
        Metadata Version:0.10
        NNC Command Protocol Version:8.0
        SBL Image:SBL.AIC.1.5.5
        PVS Image Version:18
        NSP Defective PG Mask: 0x0
        Board serial:PN471-12-343016
QID 4
        Status:Ready
        PCI Address:0000:c1:00.0
        PCI Info:Processing accelerators Qualcomm Device a100
        HW Version:0.2.0.0
        HW Serial:0x70dbd831
        FW Version:1.5.6
        FW QC_IMAGE_VERSION:QSM.AIC.1.5.6
        FW OEM_IMAGE_VERSION:
        FW IMAGE_VARIANT:AIC100.REL
        NSP Version:1.5.2
        NSP QC_IMAGE_VERSION:NSP.AIC.1.5.2
        NSP OEM_IMAGE_VERSION:
        NSP IMAGE_VARIANT:aic100.nsp.prodQ
        Compiler Version:0
        Dram Total:32692 MB
        Dram Free:32692 MB
        Dram Fragmentation:0.00%
        Vc Total:16
        Vc Free:16
        Nsp Total:16
        Nsp Free:16
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
        NSP Frequency(Mhz):825
        DDR Frequency(Mhz):2133
        COMPNOC Frequency(Mhz):1450
        MEMNOC Frequency(Mhz):1000
        SYSNOC Frequency(Mhz):667
        Metadata Version:0.10
        NNC Command Protocol Version:8.0
        SBL Image:SBL.AIC.1.5.5
        PVS Image Version:18
        NSP Defective PG Mask: 0x0
        Board serial:PN471-11-343015
QID 5
        Status:Ready
        PCI Address:0000:c2:00.0
        PCI Info:Processing accelerators Qualcomm Device a100
        HW Version:0.2.0.0
        HW Serial:0xd55e8219
        FW Version:1.5.6
        FW QC_IMAGE_VERSION:QSM.AIC.1.5.6
        FW OEM_IMAGE_VERSION:
        FW IMAGE_VARIANT:AIC100.REL
        NSP Version:1.5.2
        NSP QC_IMAGE_VERSION:NSP.AIC.1.5.2
        NSP OEM_IMAGE_VERSION:
        NSP IMAGE_VARIANT:aic100.nsp.prodQ
        Compiler Version:0
        Dram Total:32692 MB
        Dram Free:32692 MB
        Dram Fragmentation:0.00%
        Vc Total:16
        Vc Free:16
        Nsp Total:16
        Nsp Free:16
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
        NSP Frequency(Mhz):825
        DDR Frequency(Mhz):2133
        COMPNOC Frequency(Mhz):1450
        MEMNOC Frequency(Mhz):1000
        SYSNOC Frequency(Mhz):667
        Metadata Version:0.10
        NNC Command Protocol Version:8.0
        SBL Image:SBL.AIC.1.5.5
        PVS Image Version:18
        NSP Defective PG Mask: 0x0
        Board serial:PN471-11-343015
QID 6
        Status:Ready
        PCI Address:0000:21:00.0
        PCI Info:Processing accelerators Qualcomm Device a100
        HW Version:0.2.0.0
        HW Serial:0xac4998e1
        FW Version:1.5.6
        FW QC_IMAGE_VERSION:QSM.AIC.1.5.6
        FW OEM_IMAGE_VERSION:
        FW IMAGE_VARIANT:AIC100.REL
        NSP Version:1.5.2
        NSP QC_IMAGE_VERSION:NSP.AIC.1.5.2
        NSP OEM_IMAGE_VERSION:
        NSP IMAGE_VARIANT:aic100.nsp.prodQ
        Compiler Version:0
        Dram Total:32692 MB
        Dram Free:32692 MB
        Dram Fragmentation:0.00%
        Vc Total:16
        Vc Free:16
        Nsp Total:16
        Nsp Free:16
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
        NSP Frequency(Mhz):825
        DDR Frequency(Mhz):2133
        COMPNOC Frequency(Mhz):1450
        MEMNOC Frequency(Mhz):1000
        SYSNOC Frequency(Mhz):667
        Metadata Version:0.10
        NNC Command Protocol Version:8.0
        SBL Image:SBL.AIC.1.5.5
        PVS Image Version:18
        NSP Defective PG Mask: 0x0
        Board serial:PN471-12-343016
QID 7
        Status:Ready
        PCI Address:0000:22:00.0
        PCI Info:Processing accelerators Qualcomm Device a100
        HW Version:0.2.0.0
        HW Serial:0x6f3ab986
        FW Version:1.5.6
        FW QC_IMAGE_VERSION:QSM.AIC.1.5.6
        FW OEM_IMAGE_VERSION:
        FW IMAGE_VARIANT:AIC100.REL
        NSP Version:1.5.2
        NSP QC_IMAGE_VERSION:NSP.AIC.1.5.2
        NSP OEM_IMAGE_VERSION:
        NSP IMAGE_VARIANT:aic100.nsp.prodQ
        Compiler Version:0
        Dram Total:32692 MB
        Dram Free:32692 MB
        Dram Fragmentation:0.00%
        Vc Total:16
        Vc Free:16
        Nsp Total:16
        Nsp Free:16
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
        NSP Frequency(Mhz):825
        DDR Frequency(Mhz):2133
        COMPNOC Frequency(Mhz):1450
        MEMNOC Frequency(Mhz):1000
        SYSNOC Frequency(Mhz):667
        Metadata Version:0.10
        NNC Command Protocol Version:8.0
        SBL Image:SBL.AIC.1.5.5
        PVS Image Version:18
        NSP Defective PG Mask: 0x0
        Board serial:PN471-12-343016
```
        
</details>

# Docker Build (Optional)

```
ck pull repo --url=https://github.com/krai/ck-qaic
$(ck find ck-qaic:docker:bert)/build.sh DOCKER_OS=centos7 SDK_VER=1.5.9
```

```
....
Step 49/49 : CMD ["/opt/qti-aic/tools/qaic-util -q | grep Status"]
 ---> Running in 6c8c7c9afc9e
Removing intermediate container 6c8c7c9afc9e
 ---> a7fa76eedc92
Successfully built a7fa76eedc92
Successfully tagged krai/mlperf.bert.centos7:1.5.9

real    55m14.110s
user    0m11.070s
sys     0m11.121s

Done.
```
```
docker image ls
```
```
REPOSITORY                          TAG           IMAGE ID       CREATED          SIZE
krai/mlperf.bert.centos7            1.5.9         a7fa76eedc92   29 seconds ago   14.2GB
```

# BERT-99 

## BERT-99 Offline

### BERT-99 Offline Accuracy

```
docker run --privileged --user=krai:kraig --group-add $(cut -d: -f3 < <(getent group qaic)) \
--volume ${CK_EXPERIMENTS}:/home/krai/CK_REPOS/local/experiment --rm krai/mlperf.bert.centos7:1.5.9 \
"ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q8 --sdk=1.5.9 --model=bert-99 \
--mode=accuracy --scenario=offline --override_batch_size=4096 --target_qps=5200"
```

#### Submitted Result
 `"f1": 90.17090568381533`

#### Reproduced Result
<!--
```
{"exact_match": 82.47871333964049, "f1": 90.14369455973576}
Reading examples...
```
-->

```
grep -w f1 $(ck find experiment:*bert*mixed*offline*accuracy*)/*0001.json
```
`
        "f1": 90.14369455973576,
`

### BERT-99 Offline Power and Performance
```
docker run --privileged --user=krai:kraig --group-add $(cut -d: -f3 < <(getent group qaic)) \
--volume ${CK_EXPERIMENTS}:/home/krai/CK_REPOS/local/experiment --rm krai/mlperf.bert.centos7:1.5.9 \
"ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q8 --sdk=1.5.9 --model=bert-99 \
--mode=performance --scenario=offline --override_batch_size=4096 --target_qps=5200 ${POWER_pr009}"
```
<details>
  <summary>Click to see submitted result!</summary>

```
            "================================================\n",
            "MLPerf Results Summary\n",
            "================================================\n",
            "SUT name : QAIC_SUT\n",
            "Scenario : Offline\n",
            "Mode     : PerformanceOnly\n",
            "Samples per second: 5202.88\n",
            "Result is : VALID\n",
            "  Min duration satisfied : Yes\n",
            "  Min queries satisfied : Yes\n",
            "\n",
            "================================================\n",
            "Additional Stats\n",
            "================================================\n",
            "Min latency (ns)                : 13999075\n",
            "Max latency (ns)                : 659761729622\n",
            "Mean latency (ns)               : 329423860565\n",
            "50.00 percentile latency (ns)   : 329191959919\n",
            "90.00 percentile latency (ns)   : 593664133143\n",
            "95.00 percentile latency (ns)   : 626707595889\n",
            "97.00 percentile latency (ns)   : 639928739602\n",
            "99.00 percentile latency (ns)   : 653145489597\n",
            "99.90 percentile latency (ns)   : 659096294657\n",
            "\n",
            "================================================\n",
            "Test Parameters Used\n",
            "================================================\n",
            "samples_per_query : 3432660\n",
            "target_qps : 5201\n",
            "target_latency (ns): 0\n",
            "max_async_queries : 1\n",
            "min_duration (ms): 600000\n",
            "max_duration (ms): 0\n",
            "min_query_count : 1\n",
            "max_query_count : 0\n",
            "qsl_rng_seed : 1624344308455410291\n",
            "sample_index_rng_seed : 517984244576520566\n",
            "schedule_rng_seed : 10051496985653635065\n",
            "accuracy_log_rng_seed : 0\n",
            "accuracy_log_probability : 0\n",
            "accuracy_log_sampling_target : 0\n",
            "print_timestamps : 0\n",
            "performance_issue_unique : 0\n",
            "performance_issue_same : 0\n",
            "performance_issue_same_index : 0\n",
            "performance_sample_count : 10833\n",
            "\n",
            "No warnings encountered during test.\n",
            "\n",
```
 `"avg_power": 776.2986363636365`
</details>

<details>
  <summary>Click to see reproduced result!</summary>

```
      "================================================",
      "MLPerf Results Summary",
      "================================================",
      "SUT name : QAIC_SUT",
      "Scenario : Offline",
      "Mode     : PerformanceOnly",
      "Samples per second: 5198.98",
      "Result is : VALID",
      "  Min duration satisfied : Yes",
      "  Min queries satisfied : Yes",
      "",
      "================================================",
      "Additional Stats",
      "================================================",
      "Min latency (ns)                : 14090936",
      "Max latency (ns)                : 660256838559",
      "Mean latency (ns)               : 329817047771",
      "50.00 percentile latency (ns)   : 329846294837",
      "90.00 percentile latency (ns)   : 594163811798",
      "95.00 percentile latency (ns)   : 627200269038",
      "97.00 percentile latency (ns)   : 640418507259",
      "99.00 percentile latency (ns)   : 653637849827",
      "99.90 percentile latency (ns)   : 659590730193",
      "",
      "================================================",
      "Test Parameters Used",
      "================================================",
      "samples_per_query : 3432660",
      "target_qps : 5201",
      "target_latency (ns): 0",
      "max_async_queries : 1",
      "min_duration (ms): 600000",
      "max_duration (ms): 0",
      "min_query_count : 1",
      "max_query_count : 0",
      "qsl_rng_seed : 1624344308455410291",
      "sample_index_rng_seed : 517984244576520566",
      "schedule_rng_seed : 10051496985653635065",
      "accuracy_log_rng_seed : 0",
      "accuracy_log_probability : 0",
      "accuracy_log_sampling_target : 0",
      "print_timestamps : 0",
      "performance_issue_unique : 0",
      "performance_issue_same : 0",
      "performance_issue_same_index : 0",
      "performance_sample_count : 10833",
      "",
      "No warnings encountered during test.",
      "",
      "No errors encountered during test."
    ],

```
</details>        

```
grep -w 'avg_power' $(ck find experiment:*bert*mixed*offline*performance*client)/*0001.json
```
`
        "avg_power": 779.9202723146757,
`

```
grep -w 'Samples per second' $(ck find experiment:*bert*mixed*offline*performance*client)/*0001.json
```
```
            "Samples per second: 5208.34",
            "Samples per second: 5198.98",
```

### Bert-99 Offline Compliance
```
docker run --privileged --user=krai:kraig --group-add $(cut -d: -f3 < <(getent group qaic)) \
--volume ${CK_EXPERIMENTS}:/home/krai/CK_REPOS/local/experiment --rm krai/mlperf.bert.centos7:1.5.9 \
"ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q8 --sdk=1.5.9 --model=bert-99 \
--compliance,=TEST01,TEST05 --scenario=offline --override_batch_size=4096 --target_qps=5200"
```

```
ck list experiment:*bert*mixed*offline*TEST*
```
```
mlperf-closed-r282_z93_q8-qaic-v1.5.9-aic100-qaic-v1.5.9-aic100-bert-precision.mixed-offline-performance-compliance.TEST05-target_qps.5200
mlperf-closed-r282_z93_q8-qaic-v1.5.9-aic100-qaic-v1.5.9-aic100-bert-precision.mixed-offline-performance-compliance.TEST01-target_qps.5200
```


## BERT-99 Server

### BERT-99 Server Accuracy 

```
docker run --privileged --user=krai:kraig --group-add $(cut -d: -f3 < <(getent group qaic)) \
--volume ${CK_EXPERIMENTS}:/home/krai/CK_REPOS/local/experiment --rm krai/mlperf.bert.centos7:1.5.9 \
"ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q8 --sdk=1.5.9 --model=bert-99 \
--mode=accuracy --scenario=server --override_batch_size=512 \
--target_qps=4901 --max_wait=10000"
```
#### Submitted Result
 `"f1": 90.17090568381533`

#### Reproduced Result
```
grep -w f1 $(ck find experiment:*bert*mixed*server*accuracy*)/*0001.json
```
`
        "f1": 90.14369455973576,
`


### BERT-99 Server Power and Performance

```
docker run --privileged --user=krai:kraig --group-add $(cut -d: -f3 < <(getent group qaic)) \
--volume ${CK_EXPERIMENTS}:/home/krai/CK_REPOS/local/experiment --rm krai/mlperf.bert.centos7:1.5.9 \
"ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q8 --sdk=1.5.9 --model=bert-99 \
--mode=performance --scenario=server --override_batch_size=512 \
--target_qps=4901 --max_wait=10000 ${POWER_pr009}"
```
<details>
  <summary>Click to see submitted result!</summary>

```
            "================================================\n",
            "MLPerf Results Summary\n",
            "================================================\n",
            "SUT name : QAIC_SUT\n",
            "Scenario : Server\n",
            "Mode     : PerformanceOnly\n",
            "Scheduled samples per second : 4902.82\n",
            "Result is : VALID\n",
            "  Performance constraints satisfied : Yes\n",
            "  Min duration satisfied : Yes\n",
            "  Min queries satisfied : Yes\n",
            "\n",
            "================================================\n",
            "Additional Stats\n",
            "================================================\n",
            "Completed samples per second    : 4902.64\n",
            "\n",
            "Min latency (ns)                : 11928570\n",
            "Max latency (ns)                : 120344157\n",
            "Mean latency (ns)               : 30519971\n",
            "50.00 percentile latency (ns)   : 24994805\n",
            "90.00 percentile latency (ns)   : 49759111\n",
            "95.00 percentile latency (ns)   : 75542588\n",
            "97.00 percentile latency (ns)   : 89828225\n",
            "99.00 percentile latency (ns)   : 101693052\n",
            "99.90 percentile latency (ns)   : 111078799\n",
            "\n",
            "================================================\n",
            "Test Parameters Used\n",
            "================================================\n",
            "samples_per_query : 1\n",
            "target_qps : 4901\n",
            "target_latency (ns): 130000000\n",
            "max_async_queries : 0\n",
            "min_duration (ms): 600000\n",
            "max_duration (ms): 0\n",
            "min_query_count : 270336\n",
            "max_query_count : 0\n",
            "qsl_rng_seed : 1624344308455410291\n",
            "sample_index_rng_seed : 517984244576520566\n",
            "schedule_rng_seed : 10051496985653635065\n",
            "accuracy_log_rng_seed : 0\n",
            "accuracy_log_probability : 0\n",
            "accuracy_log_sampling_target : 0\n",
            "print_timestamps : 0\n",
            "performance_issue_unique : 0\n",
            "performance_issue_same : 0\n",
            "performance_issue_same_index : 0\n",
            "performance_sample_count : 10833\n",
            "\n",
```
` "avg_power": 765.1739999999991, `       
</details>
<details>
  <summary>Click to see reproduced result!</summary>

```
      "MLPerf Results Summary",
      "================================================",
      "SUT name : QAIC_SUT",
      "Scenario : Server",
      "Mode     : PerformanceOnly",
      "Scheduled samples per second : 4902.82",
      "Result is : VALID",
      "  Performance constraints satisfied : Yes",
      "  Min duration satisfied : Yes",
      "  Min queries satisfied : Yes",
      "",
      "================================================",
      "Additional Stats",
      "================================================",
      "Completed samples per second    : 4902.64",
      "",
      "Min latency (ns)                : 11995532",
      "Max latency (ns)                : 119435762",
      "Mean latency (ns)               : 33437436",
      "50.00 percentile latency (ns)   : 25733717",
      "90.00 percentile latency (ns)   : 66550601",
      "95.00 percentile latency (ns)   : 90953115",
      "97.00 percentile latency (ns)   : 97554945",
      "99.00 percentile latency (ns)   : 104795494",
      "99.90 percentile latency (ns)   : 112149510",
      "",
      "================================================",
      "Test Parameters Used",
      "================================================",
      "samples_per_query : 1",
      "target_qps : 4901",
      "target_latency (ns): 130000000",
      "max_async_queries : 0",
      "min_duration (ms): 600000",
      "max_duration (ms): 0",
      "min_query_count : 270336",
      "max_query_count : 0",
      "qsl_rng_seed : 1624344308455410291",
      "sample_index_rng_seed : 517984244576520566",
      "schedule_rng_seed : 10051496985653635065",
      "accuracy_log_rng_seed : 0",
      "accuracy_log_probability : 0",
      "accuracy_log_sampling_target : 0",
      "print_timestamps : 0",
      "performance_issue_unique : 0",
      "performance_issue_same : 0",
      "performance_issue_same_index : 0",
      "performance_sample_count : 10833",
      "",
      "No warnings encountered during test.",
      "",
      "No errors encountered during test."
    ],
```
</details>

```
grep -w 'Scheduled samples per second' $(ck find experiment:*bert*mixed*server*performance*client)/*0001.json
```
```
            "Scheduled samples per second : 4902.82",
            "Scheduled samples per second : 4902.82",
```

```
grep -w 'avg_power' $(ck find experiment:*bert*mixed*server*performance*client)/*0001.json
```
`
        "avg_power": 769.1201666666668,
`

### Bert-99 Server Compliance
```
docker run --privileged --user=krai:kraig --group-add $(cut -d: -f3 < <(getent group qaic)) \
--volume ${CK_EXPERIMENTS}:/home/krai/CK_REPOS/local/experiment --rm krai/mlperf.bert.centos7:1.5.9 \
"ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q8 --sdk=1.5.9 --model=bert-99 \
--compliance,=TEST01,TEST05 --scenario=server --override_batch_size=512 \
--target_qps=4901 --max_wait=10000"
```

```
ck list experiment:*bert*mixed*server*TEST*
```
```
mlperf-closed-r282_z93_q8-qaic-v1.5.9-aic100-qaic-v1.5.9-aic100-bert-precision.mixed-server-performance-compliance.TEST05-target_qps.4901
mlperf-closed-r282_z93_q8-qaic-v1.5.9-aic100-qaic-v1.5.9-aic100-bert-precision.mixed-server-performance-compliance.TEST01-target_qps.4901
```

# Bert-99.9

## Bert-99.9 Offline

### Bert-99.9 Offline Accuracy

```
docker run --privileged --user=krai:kraig --group-add $(cut -d: -f3 < <(getent group qaic)) \
--volume ${CK_EXPERIMENTS}:/home/krai/CK_REPOS/local/experiment --rm krai/mlperf.bert.centos7:1.5.9 \
"ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q8 --sdk=1.5.9 --model=bert-99.9 \
--mode=accuracy --scenario=offline --override_batch_size=1024 --target_qps=2700" 
```
#### Submitted Result
 `"f1": 90.79046230446818`

#### Reproduced Result

<!--
```
...
{"exact_match": 83.59508041627247, "f1": 90.79046230446818}
Reading examples...
...
```
-->

```
grep -w f1 $(ck find experiment:*bert*fp16*offline*accuracy*)/*0001.json
```
`
        "f1": 90.79046230446818,
`

### Bert-99.9 Offline Power and Performance

``` 
docker run --privileged --user=krai:kraig --group-add $(cut -d: -f3 < <(getent group qaic)) \
--volume ${CK_EXPERIMENTS}:/home/krai/CK_REPOS/local/experiment --rm krai/mlperf.bert.centos7:1.5.9 \
"ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q8 --sdk=1.5.9 --model=bert-99.9 \
--mode=performance --scenario=offline --override_batch_size=1024 --target_qps=2700 ${POWER_pr009}"
```
<details>
  <summary>Click to see submitted result!</summary>
        
``` 
            "================================================\n",
            "MLPerf Results Summary\n",
            "================================================\n",
            "SUT name : QAIC_SUT\n",
            "Scenario : Offline\n",
            "Mode     : PerformanceOnly\n",
            "Samples per second: 2664.14\n",
            "Result is : VALID\n",
            "  Min duration satisfied : Yes\n",
            "  Min queries satisfied : Yes\n",
            "\n",
            "================================================\n",
            "Additional Stats\n",
            "================================================\n",
            "Min latency (ns)                : 26110308\n",
            "Max latency (ns)                : 668883050724\n",
            "Mean latency (ns)               : 333073246362\n",
            "50.00 percentile latency (ns)   : 332488719747\n",
            "90.00 percentile latency (ns)   : 601529328415\n",
            "95.00 percentile latency (ns)   : 635196398783\n",
            "97.00 percentile latency (ns)   : 648649598813\n",
            "99.00 percentile latency (ns)   : 662140551735\n",
            "99.90 percentile latency (ns)   : 668214597872\n",
            "\n",
            "================================================\n",
            "Test Parameters Used\n",
            "================================================\n",
            "samples_per_query : 1782000\n",
            "target_qps : 2700\n",
            "target_latency (ns): 0\n",
            "max_async_queries : 1\n",
            "min_duration (ms): 600000\n",
            "max_duration (ms): 0\n",
            "min_query_count : 1\n",
            "max_query_count : 0\n",
            "qsl_rng_seed : 1624344308455410291\n",
            "sample_index_rng_seed : 517984244576520566\n",
            "schedule_rng_seed : 10051496985653635065\n",
            "accuracy_log_rng_seed : 0\n",
            "accuracy_log_probability : 0\n",
            "accuracy_log_sampling_target : 0\n",
            "print_timestamps : 0\n",
            "performance_issue_unique : 0\n",
            "performance_issue_same : 0\n",
            "performance_issue_same_index : 0\n",
            "performance_sample_count : 10833\n",
            "\n",
            "No warnings encountered during test.\n",
            "\n",
            "No errors encountered during test.\n"
```
"avg_power": 841.4444610778444,
</details>

<details>
  <summary>Click to see reproduced result!</summary>
        
```
      "================================================\n",
      "MLPerf Results Summary\n",
      "================================================\n",        
      "Scenario : Offline",
      "Mode     : PerformanceOnly",
      "Samples per second: 2642.19",
      "Result is : VALID",
      "  Min duration satisfied : Yes",
      "  Min queries satisfied : Yes",
      "",
      "================================================",
      "Additional Stats",
      "================================================",
      "Min latency (ns)                : 26379813",
      "Max latency (ns)                : 674439852022",
      "Mean latency (ns)               : 335613996224",
      "50.00 percentile latency (ns)   : 334883802570",
      "90.00 percentile latency (ns)   : 606440506711",
      "95.00 percentile latency (ns)   : 640450896356",
      "97.00 percentile latency (ns)   : 654019548216",
      "99.00 percentile latency (ns)   : 667626406897",
      "99.90 percentile latency (ns)   : 673749336851",
      "",
      "================================================",
      "Test Parameters Used",
      "================================================",
      "samples_per_query : 1782000",
      "target_qps : 2700",
      "target_latency (ns): 0",
      "max_async_queries : 1",
      "min_duration (ms): 600000",
      "max_duration (ms): 0",
      "min_query_count : 1",
      "max_query_count : 0",
      "qsl_rng_seed : 1624344308455410291",
      "sample_index_rng_seed : 517984244576520566",
      "schedule_rng_seed : 10051496985653635065",
      "accuracy_log_rng_seed : 0",
      "accuracy_log_probability : 0",
      "accuracy_log_sampling_target : 0",
      "print_timestamps : 0",
      "performance_issue_unique : 0",
      "performance_issue_same : 0",
      "performance_issue_same_index : 0",
      "performance_sample_count : 10833",
      "",
      "No warnings encountered during test.",
      "",
      "No errors encountered during test."
```
</details>

```
grep -w 'Samples per second' $(ck find experiment:*bert*fp16*offline*performance*client)/*0001.json    
```
```
            "Samples per second: 2655.84",
            "Samples per second: 2642.19",
```
```
grep -w 'avg_power' $(ck find experiment:*bert*fp16*offline*performance*client)/*0001.json
```
```
        "avg_power": 842.0051928783388,
```

### Bert-99.9 Offline Compliance

```
docker run --privileged --user=krai:kraig --group-add $(cut -d: -f3 < <(getent group qaic)) \
--volume ${CK_EXPERIMENTS}:/home/krai/CK_REPOS/local/experiment --rm krai/mlperf.bert.centos7:1.5.9 \
"ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q8 --sdk=1.5.9 --model=bert-99.9 \
--compliance,=TEST01,TEST05 --scenario=offline --override_batch_size=1024 --target_qps=2700"
```

```
ck list experiment:*bert*fp16*offline*TEST*
```
```
mlperf-closed-r282_z93_q8-qaic-v1.5.9-aic100-qaic-v1.5.9-aic100-bert-precision.fp16-offline-performance-compliance.TEST05-target_qps.2700
mlperf-closed-r282_z93_q8-qaic-v1.5.9-aic100-qaic-v1.5.9-aic100-bert-precision.fp16-offline-performance-compliance.TEST01-target_qps.2700
```

## Bert-99.9 Server

### Bert-99.9 Server Accuracy

``` 
docker run --privileged --user=krai:kraig --group-add $(cut -d: -f3 < <(getent group qaic)) \
--volume ${CK_EXPERIMENTS}:/home/krai/CK_REPOS/local/experiment --rm krai/mlperf.bert.centos7:1.5.9 \
"ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q8 --sdk=1.5.9 --model=bert-99.9 \
--mode=accuracy --scenario=server --override_batch_size=1024 \
--target_qps=2250 -- max_wait=50000"
```
#### Submitted Result
 `"f1": 90.79046230446818`

#### Reproduced Result
<!--
```
...
{"exact_match": 83.59508041627247, "f1": 90.79046230446818}
Reading examples...
...
```
-->
``` 
grep -w f1 $(ck find experiment:*bert*fp16*server*accuracy*)/*0001.json                                                               
```
`
"f1": 90.79046230446818,
`


### Bert-99.9 Server Power and Performance

``` 
docker run --privileged --user=krai:kraig --group-add $(cut -d: -f3 < <(getent group qaic)) \
--volume ${CK_EXPERIMENTS}:/home/krai/CK_REPOS/local/experiment --rm krai/mlperf.bert.centos7:1.5.9 \
"ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q8 --sdk=1.5.9 --model=bert-99.9 \
--mode=performance --scenario=server --override_batch_size=1024 \
--target_qps=2250 -- max_wait=50000 ${POWER_pr009}"
```
<details>
  <summary>Click to see submitted result!</summary>

```
            "================================================\n",
            "MLPerf Results Summary\n",
            "================================================\n",
            "SUT name : QAIC_SUT\n",
            "Scenario : Server\n",
            "Mode     : PerformanceOnly\n",
            "Scheduled samples per second : 2250.17\n",
            "Result is : VALID\n",
            "  Performance constraints satisfied : Yes\n",
            "  Min duration satisfied : Yes\n",
            "  Min queries satisfied : Yes\n",
            "\n",
            "================================================\n",
            "Additional Stats\n",
            "================================================\n",
            "Completed samples per second    : 2249.93\n",
            "\n",
            "Min latency (ns)                : 19968483\n",
            "Max latency (ns)                : 150365372\n",
            "Mean latency (ns)               : 61351091\n",
            "50.00 percentile latency (ns)   : 61193855\n",
            "90.00 percentile latency (ns)   : 88590474\n",
            "95.00 percentile latency (ns)   : 93988357\n",
            "97.00 percentile latency (ns)   : 96350092\n",
            "99.00 percentile latency (ns)   : 100348736\n",
            "99.90 percentile latency (ns)   : 113283742\n",
            "\n",
            "================================================\n",
            "Test Parameters Used\n",
            "================================================\n",
            "samples_per_query : 1\n",
            "target_qps : 2250\n",
            "target_latency (ns): 130000000\n",
            "max_async_queries : 0\n",
            "min_duration (ms): 600000\n",
            "max_duration (ms): 0\n",
            "min_query_count : 270336\n",
            "max_query_count : 0\n",
            "qsl_rng_seed : 1624344308455410291\n",
            "sample_index_rng_seed : 517984244576520566\n",
            "schedule_rng_seed : 10051496985653635065\n",
            "accuracy_log_rng_seed : 0\n",
            "accuracy_log_probability : 0\n",
            "accuracy_log_sampling_target : 0\n",
            "print_timestamps : 0\n",
            "performance_issue_unique : 0\n",
            "performance_issue_same : 0\n",
            "performance_issue_same_index : 0\n",
            "performance_sample_count : 10833\n",
            "\n",
            "No warnings encountered during test.\n",
            "\n",

```
` "avg_power": 763.915973377704`
</details>        
<details>
  <summary>Click to see reproduced result!</summary>
        
```
      "================================================",
      "MLPerf Results Summary",
      "================================================",
      "SUT name : QAIC_SUT",
      "Scenario : Server",
      "Mode     : PerformanceOnly",
      "Scheduled samples per second : 2250.17",
      "Result is : VALID",
      "  Performance constraints satisfied : Yes",
      "  Min duration satisfied : Yes",
      "  Min queries satisfied : Yes",
      "",
      "================================================",
      "Additional Stats",
      "================================================",
      "Completed samples per second    : 2249.94",
      "",
      "Min latency (ns)                : 20896949",
      "Max latency (ns)                : 192845992",
      "Mean latency (ns)               : 61818768",
      "50.00 percentile latency (ns)   : 61619611",
      "90.00 percentile latency (ns)   : 89210796",
      "95.00 percentile latency (ns)   : 94631954",
      "97.00 percentile latency (ns)   : 97096347",
      "99.00 percentile latency (ns)   : 101571638",
      "99.90 percentile latency (ns)   : 117850788",
      "",
      "================================================",
      "Test Parameters Used",
      "================================================",
      "samples_per_query : 1",
      "target_qps : 2250",
      "target_latency (ns): 130000000",
      "max_async_queries : 0",
      "min_duration (ms): 600000",
      "max_duration (ms): 0",
      "min_query_count : 270336",
      "max_query_count : 0",
      "qsl_rng_seed : 1624344308455410291",
      "sample_index_rng_seed : 517984244576520566",
      "schedule_rng_seed : 10051496985653635065",
      "accuracy_log_rng_seed : 0",
      "accuracy_log_probability : 0",
      "accuracy_log_sampling_target : 0",
      "print_timestamps : 0",
      "performance_issue_unique : 0",
      "performance_issue_same : 0",
      "performance_issue_same_index : 0",
      "performance_sample_count : 10833",
      "",
      "No warnings encountered during test.",
      "",
      "No errors encountered during test."
...
```
</details>


``` 
grep -w 'Scheduled samples per second' $(ck find experiment:*bert*fp16*server*performance*client)/*0001.json
```
```
            "Scheduled samples per second : 2250.17",
            "Scheduled samples per second : 2250.17",
```

``` 
grep -w 'avg_power' $(ck find experiment:*bert*fp16*server*performance*client)/*0001.json
```
`
        "avg_power": 769.2759999999993,
`

### Bert-99.9 Server Compliance 

```
docker run --privileged --user=krai:kraig --group-add $(cut -d: -f3 < <(getent group qaic)) \
--volume ${CK_EXPERIMENTS}:/home/krai/CK_REPOS/local/experiment --rm krai/mlperf.bert.centos7:1.5.9 \
"ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q8 --sdk=1.5.9 --model=bert-99.9 \
--compliance,=TEST01,TEST05 --scenario=server --override_batch_size=1024 \
--target_qps=2250 -- max_wait=50000"
```

```
ck list experiment:*bert*fp16*server*TEST*
```
```
mlperf-closed-r282_z93_q8-qaic-v1.5.9-aic100-qaic-v1.5.9-aic100-bert-precision.fp16-server-performance-compliance.TEST01-target_qps.2250
mlperf-closed-r282_z93_q8-qaic-v1.5.9-aic100-qaic-v1.5.9-aic100-bert-precision.fp16-server-performance-compliance.TEST05-target_qps.2250
```

# Dump Repo to Submission

## List all the experiments

```
ck list mlperf.aus655-pci-bowie:experiment:*
```
```
mlperf-closed-r282_z93_q8-qaic-v1.5.9-aic100-qaic-v1.5.9-aic100-bert-precision.fp16-server-performance-target_qps.2250-power.workload
mlperf-closed-r282_z93_q8-qaic-v1.5.9-aic100-qaic-v1.5.9-aic100-bert-precision.fp16-offline-performance-compliance.TEST05-target_qps.2700
mlperf-closed-r282_z93_q8-qaic-v1.5.9-aic100-qaic-v1.5.9-aic100-bert-precision.mixed-offline-performance-target_qps.5201-power.workload
mlperf-closed-r282_z93_q8-qaic-v1.5.9-aic100-qaic-v1.5.9-aic100-bert-precision.mixed-server-performance-target_qps.4901-power.workload
mlperf-closed-r282_z93_q8-qaic-v1.5.9-aic100-qaic-v1.5.9-aic100-bert-precision.mixed-offline-performance-target_qps.5201-power.client
mlperf-closed-r282_z93_q8-qaic-v1.5.9-aic100-qaic-v1.5.9-aic100-bert-precision.fp16-offline-accuracy-dataset_size.10833-target_qps.2700
mlperf-closed-r282_z93_q8-qaic-v1.5.9-aic100-qaic-v1.5.9-aic100-bert-precision.mixed-offline-performance-compliance.TEST05-target_qps.5200
mlperf-closed-r282_z93_q8-qaic-v1.5.9-aic100-qaic-v1.5.9-aic100-bert-precision.fp16-server-performance-target_qps.2250-power.client
mlperf-closed-r282_z93_q8-qaic-v1.5.9-aic100-qaic-v1.5.9-aic100-bert-precision.fp16-server-performance-compliance.TEST01-target_qps.2250
mlperf-closed-r282_z93_q8-qaic-v1.5.9-aic100-qaic-v1.5.9-aic100-bert-precision.mixed-server-performance-compliance.TEST05-target_qps.4901
mlperf-closed-r282_z93_q8-qaic-v1.5.9-aic100-qaic-v1.5.9-aic100-bert-precision.mixed-offline-accuracy-dataset_size.10833-target_qps.5200
mlperf-closed-r282_z93_q8-qaic-v1.5.9-aic100-qaic-v1.5.9-aic100-bert-precision.fp16-offline-performance-target_qps.2700-power.client
mlperf-closed-r282_z93_q8-qaic-v1.5.9-aic100-qaic-v1.5.9-aic100-bert-precision.fp16-offline-performance-compliance.TEST01-target_qps.2700
mlperf-closed-r282_z93_q8-qaic-v1.5.9-aic100-qaic-v1.5.9-aic100-bert-precision.mixed-server-performance-compliance.TEST01-target_qps.4901
mlperf-closed-r282_z93_q8-qaic-v1.5.9-aic100-qaic-v1.5.9-aic100-bert-precision.mixed-server-performance-target_qps.4901-power.client
mlperf-closed-r282_z93_q8-qaic-v1.5.9-aic100-qaic-v1.5.9-aic100-bert-precision.mixed-server-accuracy-dataset_size.10833-target_qps.4901
mlperf-closed-r282_z93_q8-qaic-v1.5.9-aic100-qaic-v1.5.9-aic100-bert-precision.fp16-server-accuracy-dataset_size.10833-target_qps.2250
mlperf-closed-r282_z93_q8-qaic-v1.5.9-aic100-qaic-v1.5.9-aic100-bert-precision.fp16-offline-performance-target_qps.2700-power.workload
mlperf-closed-r282_z93_q8-qaic-v1.5.9-aic100-qaic-v1.5.9-aic100-bert-precision.fp16-server-performance-compliance.TEST05-target_qps.2250
mlperf-closed-r282_z93_q8-qaic-v1.5.9-aic100-qaic-v1.5.9-aic100-bert-precision.mixed-offline-performance-compliance.TEST01-target_qps.5200
```
*We should have 5\*4 = 20 experiments (2 power, 1 accuracy and 2 compliance runs for each benchmark scenario)*

**To remove any of the above experiments**
`ck rm experiment:<experiment_folder_name>`

**Install CK dependency packages for accuracy verification**

```
ck detect soft:compiler.python --full_path=`which python3.8`
ck install package --tags=mlperf,inference,r1.1
ck install package --tags=squad,original
ck install package --tags=dataset,tokenization,vocab
ck install package --tags=lib,python-package,absl
ck install package --tags=lib,python-package,transformers --force_version=2.4.0
ck install package --tags=dataset,squad,tokenized,raw
```

Some MLPerf verification scripts require NumPy for the default Python v3, so we need to install it too:

```
python3 -m pip install numpy --user
```

## Run the Submission Generation Script

```
rm -rf /tmp/inference_results_v1.1
python3.8 /local/mnt/workspace/mlcommons/tools/mlperf-inference/dump-repo-to-submission/main.py \
--submitter=Qualcomm --inference-src $(ck locate env \
--tags=mlperf,inference,r1.1)/inference \
--repo-uoa "mlperf.aus655-pci-bowie" \
--squad-original $(ck locate env --tags=squad,original)/dev-v1.1.json \
--vocab-file $(ck locate env --tags=vocab,tokenization)/vocab.txt \
--squad-tokenized $(ck locate env \
--tags=dataset,squad,tokenized)/bert_tokenized_squad_v1_1.pickle \
--output '/tmp/inference_results_v1.1'
```

```
....
[INFO] Results table:
[INFO]   r282_z93_q8-qaic-v1.5.9-aic100/bert-99   |  compliance.TEST05,mode.performance,scenario.offline compliance.TEST01,mode.performance,scenario.server mode.accuracy,scenario.offline mode.performance,power,scenario.offline mode.accuracy,scenario.server compliance.TEST01,mode.performance,scenario.offline mode.performance,power,scenario.server compliance.TEST05,mode.performance,scenario.server
[INFO]   r282_z93_q8-qaic-v1.5.9-aic100/bert-99.9 |  compliance.TEST05,mode.performance,scenario.offline compliance.TEST01,mode.performance,scenario.server mode.accuracy,scenario.offline mode.performance,power,scenario.offline mode.accuracy,scenario.server compliance.TEST01,mode.performance,scenario.offline mode.performance,power,scenario.server compliance.TEST05,mode.performance,scenario.server
[INFO] Result DB table:
[INFO]
[INFO]   platform    | inference_engine_version | benchmark | scenario | mode        | compliance | power   | value                    |
[INFO]   ___________ | ________________________ | _________ | ________ | ___________ | __________ | _______ | ________________________ |
[INFO]   r282_z93_q8 | v1.5.9                   | bert-99   | offline  | accuracy    | None       | None    | 90.144%                  |
[INFO]   r282_z93_q8 | v1.5.9                   | bert-99   | offline  | performance | None       | 779.920 | 5198.98 (QPS)            |
[INFO]   r282_z93_q8 | v1.5.9                   | bert-99   | offline  | performance | TEST01     | None    | 5243.26 (QPS)            |
[INFO]   r282_z93_q8 | v1.5.9                   | bert-99   | offline  | performance | TEST05     | None    | 5235.96 (QPS)            |
[INFO]   r282_z93_q8 | v1.5.9                   | bert-99   | server   | accuracy    | None       | None    | 90.144%                  |
[INFO]   r282_z93_q8 | v1.5.9                   | bert-99   | server   | performance | None       | 769.120 | 4902.82 (QPS)            |
[INFO]   r282_z93_q8 | v1.5.9                   | bert-99   | server   | performance | TEST01     | None    | 4903.74 (QPS)            |
[INFO]   r282_z93_q8 | v1.5.9                   | bert-99   | server   | performance | TEST05     | None    | 4899.42 (QPS)            |
[INFO]   r282_z93_q8 | v1.5.9                   | bert-99.9 | offline  | accuracy    | None       | None    | 90.790%                  |
[INFO]   r282_z93_q8 | v1.5.9                   | bert-99.9 | offline  | performance | None       | 842.005 | 2642.19 (QPS)            |
[INFO]   r282_z93_q8 | v1.5.9                   | bert-99.9 | offline  | performance | TEST01     | None    | 2669.81 (QPS)            |
[INFO]   r282_z93_q8 | v1.5.9                   | bert-99.9 | offline  | performance | TEST05     | None    | 2654.25 (QPS)            |
[INFO]   r282_z93_q8 | v1.5.9                   | bert-99.9 | server   | accuracy    | None       | None    | 90.790%                  |
[INFO]   r282_z93_q8 | v1.5.9                   | bert-99.9 | server   | performance | None       | 769.276 | 2250.17 (QPS)            |
[INFO]   r282_z93_q8 | v1.5.9                   | bert-99.9 | server   | performance | TEST01     | None    | 2251.17 (QPS)            |
[INFO]   r282_z93_q8 | v1.5.9                   | bert-99.9 | server   | performance | TEST05     | None    | 2249.05 (QPS)            |


Platform     Inference Engine Version    Benchmark      offline_accuracy    Queries per Second    Power  Compliance      server_accuracy    Queries per Second    Power  Compliance
-----------  --------------------------  -----------  ------------------  --------------------  -------  ------------  -----------------  --------------------  -------  ------------
r282_z93_q8  v1.5.9                      bert-99                  90.144               5198.98  779.92   Passed                   90.144               4902.82  769.12   Passed
r282_z93_q8  v1.5.9                      bert-99.9                90.79                2642.19  842.005  Passed                   90.79                2250.17  769.276  Passed

Total 0 errors, 0 warnings
```

## Run the Submission Checker
```
python3.8 $(ck locate env --tags=mlperf,inference,r1.1)/inference/tools/submission/submission-checker.py  \
--submitter Qualcomm \
--version v1.1 \
--input /tmp/inference_results_v1.1 2>&1 \
| /local/mnt/workspace/mlcommons/tools/mlperf-inference/dump-repo-to-submission/colorize.py
```
```
INFO    Sucessfully loaded MLPerf log from closed/Qualcomm/results/r282_z93_q8-qaic-v1.5.9-aic100/bert-99.9/server/accuracy/mlperf_log_detail.txt.
INFO    Detected power logs for closed/Qualcomm/results/r282_z93_q8-qaic-v1.5.9-aic100/bert-99.9/server
INFO    Sucessfully loaded MLPerf log from closed/Qualcomm/results/r282_z93_q8-qaic-v1.5.9-aic100/bert-99.9/server/performance/run_1/mlperf_log_detail.txt.
INFO    Sucessfully loaded MLPerf log from closed/Qualcomm/results/r282_z93_q8-qaic-v1.5.9-aic100/bert-99.9/server/performance/run_1/mlperf_log_detail.txt.
INFO    Sucessfully loaded MLPerf log from closed/Qualcomm/results/r282_z93_q8-qaic-v1.5.9-aic100/bert-99.9/server/performance/run_1/mlperf_log_detail.txt.
INFO    closed/Qualcomm/compliance/r282_z93_q8-qaic-v1.5.9-aic100/bert-99.9/server/TEST01/accuracy has file list mismatch (['baseline_accuracy.txt', 'compliance_accuracy.txt'])
INFO    Sucessfully loaded MLPerf log from closed/Qualcomm/results/r282_z93_q8-qaic-v1.5.9-aic100/bert-99.9/offline/accuracy/mlperf_log_detail.txt.
INFO    Detected power logs for closed/Qualcomm/results/r282_z93_q8-qaic-v1.5.9-aic100/bert-99.9/offline
INFO    Sucessfully loaded MLPerf log from closed/Qualcomm/results/r282_z93_q8-qaic-v1.5.9-aic100/bert-99.9/offline/performance/run_1/mlperf_log_detail.txt.
INFO    Sucessfully loaded MLPerf log from closed/Qualcomm/results/r282_z93_q8-qaic-v1.5.9-aic100/bert-99.9/offline/performance/run_1/mlperf_log_detail.txt.
INFO    Sucessfully loaded MLPerf log from closed/Qualcomm/results/r282_z93_q8-qaic-v1.5.9-aic100/bert-99.9/offline/performance/run_1/mlperf_log_detail.txt.
INFO    closed/Qualcomm/compliance/r282_z93_q8-qaic-v1.5.9-aic100/bert-99.9/offline/TEST01/accuracy has file list mismatch (['baseline_accuracy.txt', 'compliance_accuracy.txt'])
INFO    Sucessfully loaded MLPerf log from closed/Qualcomm/results/r282_z93_q8-qaic-v1.5.9-aic100/bert-99/server/accuracy/mlperf_log_detail.txt.
INFO    Detected power logs for closed/Qualcomm/results/r282_z93_q8-qaic-v1.5.9-aic100/bert-99/server
INFO    Sucessfully loaded MLPerf log from closed/Qualcomm/results/r282_z93_q8-qaic-v1.5.9-aic100/bert-99/server/performance/run_1/mlperf_log_detail.txt.
INFO    Sucessfully loaded MLPerf log from closed/Qualcomm/results/r282_z93_q8-qaic-v1.5.9-aic100/bert-99/server/performance/run_1/mlperf_log_detail.txt.
INFO    Sucessfully loaded MLPerf log from closed/Qualcomm/results/r282_z93_q8-qaic-v1.5.9-aic100/bert-99/server/performance/run_1/mlperf_log_detail.txt.
INFO    closed/Qualcomm/compliance/r282_z93_q8-qaic-v1.5.9-aic100/bert-99/server/TEST01/accuracy has file list mismatch (['baseline_accuracy.txt', 'compliance_accuracy.txt'])
INFO    Sucessfully loaded MLPerf log from closed/Qualcomm/results/r282_z93_q8-qaic-v1.5.9-aic100/bert-99/offline/accuracy/mlperf_log_detail.txt.
INFO    Detected power logs for closed/Qualcomm/results/r282_z93_q8-qaic-v1.5.9-aic100/bert-99/offline
INFO    Sucessfully loaded MLPerf log from closed/Qualcomm/results/r282_z93_q8-qaic-v1.5.9-aic100/bert-99/offline/performance/run_1/mlperf_log_detail.txt.
INFO    Sucessfully loaded MLPerf log from closed/Qualcomm/results/r282_z93_q8-qaic-v1.5.9-aic100/bert-99/offline/performance/run_1/mlperf_log_detail.txt.
INFO    Sucessfully loaded MLPerf log from closed/Qualcomm/results/r282_z93_q8-qaic-v1.5.9-aic100/bert-99/offline/performance/run_1/mlperf_log_detail.txt.
INFO    closed/Qualcomm/compliance/r282_z93_q8-qaic-v1.5.9-aic100/bert-99/offline/TEST01/accuracy has file list mismatch (['baseline_accuracy.txt', 'compliance_accuracy.txt'])
INFO    ---
INFO    Results closed/Qualcomm/results/r282_z93_q8-qaic-v1.5.9-aic100/bert-99.9/offline 2642.190000 with power_metric = 842.005193
INFO    Results closed/Qualcomm/results/r282_z93_q8-qaic-v1.5.9-aic100/bert-99.9/server 2250.170000 with power_metric = 769.276000
INFO    Results closed/Qualcomm/results/r282_z93_q8-qaic-v1.5.9-aic100/bert-99/offline 5198.980000 with power_metric = 779.920272
INFO    Results closed/Qualcomm/results/r282_z93_q8-qaic-v1.5.9-aic100/bert-99/server 4902.820000 with power_metric = 769.120167
INFO    ---
INFO    ---
INFO    Results=4, NoResults=0
INFO    SUMMARY: submission looks OK

0 errors, 0 warnings, 33 infos
```

### Run the Submission Checker with More Power Checks

```
python3.8 $(ck locate env --tags=mlperf,inference,r1.1)/inference/tools/submission/submission-checker.py  --submitter Qualcomm --version v1.1 --input /tmp/inference_results_v1.1 --more-power-check 2>&1 | /local/mnt/workspace/mlcommons/tools/mlperf-inference/dump-repo-to-submission/colorize.py
```
<details>
        <summary>Click here to view full output</summary>
        
```        
INFO    Sucessfully loaded MLPerf log from closed/Qualcomm/results/r282_z93_q8-qaic-v1.5.9-aic100/bert-99.9/server/accuracy/mlperf_log_detail.txt.
INFO    Detected power logs for closed/Qualcomm/results/r282_z93_q8-qaic-v1.5.9-aic100/bert-99.9/server
INFO    Sucessfully loaded MLPerf log from closed/Qualcomm/results/r282_z93_q8-qaic-v1.5.9-aic100/bert-99.9/server/performance/run_1/mlperf_log_detail.txt.
INFO    Sucessfully loaded MLPerf log from closed/Qualcomm/results/r282_z93_q8-qaic-v1.5.9-aic100/bert-99.9/server/performance/run_1/mlperf_log_detail.txt.
INFO    Sucessfully loaded MLPerf log from closed/Qualcomm/results/r282_z93_q8-qaic-v1.5.9-aic100/bert-99.9/server/performance/run_1/mlperf_log_detail.txt.
[x] Check client sources checksum

[x] Check server sources checksum

[x] Check PTD commands and replies

[x] Check UUID

[x] Check session name

[x] Check time difference

[x] Check client server messages

[x] Check results checksum

[x] Check errors and warnings from PTD logs

        '10-05-2021 16:31:59.095: ERROR: Bad watts reading nan from WT310' in ptd_log.txt during ranging stage. Treated as WARNING



[x] Check PTD configuration

[x] Check debug is disabled on server-side



All checks passed. Warnings encountered, check for audit!

INFO    closed/Qualcomm/compliance/r282_z93_q8-qaic-v1.5.9-aic100/bert-99.9/server/TEST01/accuracy has file list mismatch (['compliance_accuracy.txt', 'baseline_accuracy.txt'])
INFO    Sucessfully loaded MLPerf log from closed/Qualcomm/results/r282_z93_q8-qaic-v1.5.9-aic100/bert-99.9/offline/accuracy/mlperf_log_detail.txt.
INFO    Detected power logs for closed/Qualcomm/results/r282_z93_q8-qaic-v1.5.9-aic100/bert-99.9/offline
INFO    Sucessfully loaded MLPerf log from closed/Qualcomm/results/r282_z93_q8-qaic-v1.5.9-aic100/bert-99.9/offline/performance/run_1/mlperf_log_detail.txt.
INFO    Sucessfully loaded MLPerf log from closed/Qualcomm/results/r282_z93_q8-qaic-v1.5.9-aic100/bert-99.9/offline/performance/run_1/mlperf_log_detail.txt.
INFO    Sucessfully loaded MLPerf log from closed/Qualcomm/results/r282_z93_q8-qaic-v1.5.9-aic100/bert-99.9/offline/performance/run_1/mlperf_log_detail.txt.
[x] Check client sources checksum

[x] Check server sources checksum

[x] Check PTD commands and replies

[x] Check UUID

[x] Check session name

[x] Check time difference

[x] Check client server messages

[x] Check results checksum

[x] Check errors and warnings from PTD logs

        '10-05-2021 15:33:29.106: ERROR: Bad watts reading nan from WT310' in ptd_log.txt during ranging stage. Treated as WARNING



[x] Check PTD configuration

[x] Check debug is disabled on server-side



All checks passed. Warnings encountered, check for audit!

INFO    closed/Qualcomm/compliance/r282_z93_q8-qaic-v1.5.9-aic100/bert-99.9/offline/TEST01/accuracy has file list mismatch (['compliance_accuracy.txt', 'baseline_accuracy.txt'])
INFO    Sucessfully loaded MLPerf log from closed/Qualcomm/results/r282_z93_q8-qaic-v1.5.9-aic100/bert-99/server/accuracy/mlperf_log_detail.txt.
INFO    Detected power logs for closed/Qualcomm/results/r282_z93_q8-qaic-v1.5.9-aic100/bert-99/server
INFO    Sucessfully loaded MLPerf log from closed/Qualcomm/results/r282_z93_q8-qaic-v1.5.9-aic100/bert-99/server/performance/run_1/mlperf_log_detail.txt.
INFO    Sucessfully loaded MLPerf log from closed/Qualcomm/results/r282_z93_q8-qaic-v1.5.9-aic100/bert-99/server/performance/run_1/mlperf_log_detail.txt.
INFO    Sucessfully loaded MLPerf log from closed/Qualcomm/results/r282_z93_q8-qaic-v1.5.9-aic100/bert-99/server/performance/run_1/mlperf_log_detail.txt.
[x] Check client sources checksum

[x] Check server sources checksum

[x] Check PTD commands and replies

[x] Check UUID

[x] Check session name

[x] Check time difference

[x] Check client server messages

[x] Check results checksum

[x] Check errors and warnings from PTD logs

        '10-05-2021 14:14:42.628: ERROR: Bad watts reading nan from WT310' in ptd_log.txt during ranging stage. Treated as WARNING



[x] Check PTD configuration

[x] Check debug is disabled on server-side



All checks passed. Warnings encountered, check for audit!

INFO    closed/Qualcomm/compliance/r282_z93_q8-qaic-v1.5.9-aic100/bert-99/server/TEST01/accuracy has file list mismatch (['compliance_accuracy.txt', 'baseline_accuracy.txt'])
INFO    Sucessfully loaded MLPerf log from closed/Qualcomm/results/r282_z93_q8-qaic-v1.5.9-aic100/bert-99/offline/accuracy/mlperf_log_detail.txt.
INFO    Detected power logs for closed/Qualcomm/results/r282_z93_q8-qaic-v1.5.9-aic100/bert-99/offline
INFO    Sucessfully loaded MLPerf log from closed/Qualcomm/results/r282_z93_q8-qaic-v1.5.9-aic100/bert-99/offline/performance/run_1/mlperf_log_detail.txt.
INFO    Sucessfully loaded MLPerf log from closed/Qualcomm/results/r282_z93_q8-qaic-v1.5.9-aic100/bert-99/offline/performance/run_1/mlperf_log_detail.txt.
INFO    Sucessfully loaded MLPerf log from closed/Qualcomm/results/r282_z93_q8-qaic-v1.5.9-aic100/bert-99/offline/performance/run_1/mlperf_log_detail.txt.
[x] Check client sources checksum

[x] Check server sources checksum

[x] Check PTD commands and replies

[x] Check UUID

[x] Check session name

[x] Check time difference

[x] Check client server messages

[x] Check results checksum

[x] Check errors and warnings from PTD logs

        '10-05-2021 13:09:53.851: ERROR: Bad watts reading nan from WT310' in ptd_log.txt during ranging stage. Treated as WARNING



[x] Check PTD configuration

[x] Check debug is disabled on server-side
```
</details>
        
```
All checks passed. Warnings encountered, check for audit!

INFO    closed/Qualcomm/compliance/r282_z93_q8-qaic-v1.5.9-aic100/bert-99/offline/TEST01/accuracy has file list mismatch (['compliance_accuracy.txt', 'baseline_accuracy.txt'])
INFO    ---
INFO    Results closed/Qualcomm/results/r282_z93_q8-qaic-v1.5.9-aic100/bert-99.9/offline 2642.190000 with power_metric = 842.005193
INFO    Results closed/Qualcomm/results/r282_z93_q8-qaic-v1.5.9-aic100/bert-99.9/server 2250.170000 with power_metric = 769.276000
INFO    Results closed/Qualcomm/results/r282_z93_q8-qaic-v1.5.9-aic100/bert-99/offline 5198.980000 with power_metric = 779.920272
INFO    Results closed/Qualcomm/results/r282_z93_q8-qaic-v1.5.9-aic100/bert-99/server 4902.820000 with power_metric = 769.120167
INFO    ---
INFO    ---
INFO    Results=4, NoResults=0
INFO    SUMMARY: submission looks OK

0 errors, 0 warnings, 33 infos
```
