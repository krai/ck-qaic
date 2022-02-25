# Qualcomm Cloud AI - MLPerf Inference - Run All Experiments

Run all experiments for a system-under-test.

## Systems

### Q18
```
SDK_VER=1.6.80 POWER=yes SUT=pf003 DOCKER=yes ./run_datacenter.sh
```
```
SDK_VER=1.6.80 POWER=yes SUT=pf002 DOCKER=yes ./run_datacenter.sh
```

### Q16
```
SDK_VER=1.6.80 SUT=g292_z43_q16 DOCKER=yes ./run_datacenter.sh
```

### Q8
```
SDK_VER=1.6.80 POWER=yes SUT=r282_z93_q8 DOCKER=yes ./run_datacenter.sh
```

### Q5
```
SDK_VER=1.6.80 POWER=yes SUT=r282_z93_q5 DOCKER=yes ./run_edge.sh
```

### Q1
```
SDK_VER=1.6.80 SUT=r282_z93_q1 DOCKER=yes ./run_edge.sh
```

### AEDK @ 15W TDP
```
SDK_VER=1.6.80 POWER=yes SUT=aedk_15w ./run_edge.sh
```

### AEDK @ 20W TDP
```
SDK_VER=1.6.80 POWER=yes SUT=aedk_20w ./run_edge.sh
```

### Haishen
```
SDK_VER=1.6.80 SUT=aedkh ./run_edge.sh
```

### Gloria
```
SDK_VER=1.6.80 SUT=aedkg ./run_edge.sh
```

## Arguments

### `DEFS_DIR`

Default: `defs`. The directory where SUT specific performance values including TARGET QPS, TARGET LATENCY etc. are defined.

### `SDK_VER`

The SDK version. Must be set.

### `WORKLOADS`

Defaults: 
- `run_datacenter.sh`: `WORKLOADS="resnet50,ssd_resnet34,bert"`
- `run_edge.sh`: `WORKLOADS="resnet50,ssd_mobilenet,ssd_resnet34,bert"`

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
