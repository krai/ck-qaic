# Qualcomm Cloud AI - MLPerf Inference - Run All Experiments

Run all experiments for a system-under-test.

## Systems

### Q18
```
SUT=g292_z43_q18 SDK_VER=1.6.80 POWER=no DOCKER=yes ./run_datacenter.sh
```

### Q18e
```
SUT=g292_z43_q18e SDK_VER=1.6.80 POWER=yes DOCKER=yes ./run_datacenter.sh
```

### Q16
```
SUT=g292_z43_q16 SDK_VER=1.6.80 POWER=no DOCKER=yes ./run_datacenter.sh
```

### Q16e
```
SUT=g292_z43_q16e SDK_VER=1.6.80 POWER=yes DOCKER=yes ./run_datacenter.sh
```

### Q8
```
SUT=r282_z93_q8 SDK_VER=1.6.80 POWER=no DOCKER=yes ./run_datacenter.sh
```

### Q8e
```
SUT=r282_z93_q8e SDK_VER=1.6.80 POWER=yes DOCKER=yes ./run_datacenter.sh
```

### Q5
```
SUT=r282_z93_q5 SDK_VER=1.6.80 POWER=no DOCKER=yes ./run_edge.sh
```

### Q5e
```
SSUT=r282_z93_q5e DK_VER=1.6.80 POWER=yes DOCKER=yes ./run_edge.sh
```

### Q2
```
SUT=r282_z93_q2 SDK_VER=1.6.80 POWER=no DOCKER=yes ./run_edge.sh
```

### Q1
```
SUT=r282_z93_q1 SDK_VER=1.6.80 POWER=no DOCKER=yes ./run_edge.sh
```

### AEDK @ 15W TDP
```
SUT=aedk_15w SDK_VER=1.6.80 POWER=yes ./run_edge.sh
```

### AEDK @ 20W TDP
```
SUT=aedk_20w SDK_VER=1.6.80 POWER=yes ./run_edge.sh
```

### AEDK @ 25W TDP
```
SUT=aedk_25w SDK_VER=1.6.80 POWER=yes ./run_edge.sh
```

### Haishen
```
SUT=haishen SDK_VER=1.6.80 ./run_edge.sh
```

### Gloria
```
SUT=gloria SDK_VER=1.6.80 ./run_edge.sh
```

## Arguments

### `SDK_VER`

The SDK version. Must be set.

### `DEFS_DIR`

Default: `DEFS_DIR=./defs`. A directory containing SUT-specific files `def_<SUT>.sh`, defining values such as `<WORKLOAD>_<SCENARIO>_TARGET_QPS` and  `<WORKLOAD>_<SCENARIO>_TARGET_LATENCY`.

### `WORKLOADS`

Defaults: 
- `run_datacenter.sh`: `WORKLOADS="resnet50,bert"`
- `run_edge.sh`: `WORKLOADS="resnet50,bert"`

The list of workloads to run.

### `UPDATE_CK_QAIC`

Default: `UPDATE_CK_QAIC=yes`. If `UPDATE_CK_QAIC=no`, do not update the `ck-qaic` repo before the run.

### `DRY_RUN`

Default: `DRY_RUN=no`. If `DRY_RUN=yes`, only print the commands, do not make any runs.

### `SHORT_RUN`

Default: `SHORT_RUN=no`. If `SHORT_RUN=yes`, the execution time is reduced by a factor of 5 (i.e. to about 2 minutes). The results will be `INVALID`.

### `QUICK_RUN`

Default: `SHORT_RUN=no`. If `QUICK_RUN=yes`, do a quick run (< 1 minute) to see if everything is OK. The results will be `INVALID`.

### `POWER`

Default: `POWER=no`. If `POWER=yes`, measure power consumption during performance experiments. (The execution time of these experiments will roughly double due to the additional power ranging run.)

### `DIVISION`

Default: `DIVISION=open`. If `DIVISION=closed`, run all applicable compliance tests.

### `OFFLINE_ONLY`

Default: `OFFLINE_ONLY=no`. If `OFFLINE_ONLY`, run only the offline scenario in performance mode.

### `ZIP_EXPERIMENT`

If `ZIP_EXPERIMENT=yes`, after the run, create zip archive of the experiment repository in the `$HOME/krai_experiment_results/$SDK_VER` directory. Default: `ZIP_EXPERIMENT=no`.

### `ZIP_FILE`

Give custom name to the zip archive of the experiment repository. Default: `ZIP_FILE=mlperf_v${MLPERF_VER}-closed-${SUT}-qaic-v${SDK_VER}.zip`.
