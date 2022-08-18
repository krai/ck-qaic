# Qualcomm Cloud AI - MLPerf BERT Docker image

## Docker Build

### With default Percentile Calibration Value
```
WORKSPACE_DIR=/local/mnt/workspace SDK_VER=1.7.1.12 COMPILE_PRO=yes COMPILE_STD=no DOCKER_OS=ubuntu $(ck find repo:ck-qaic)/docker/build.sh bert
```

### With Exploration of best Percentile Calibration Value 
Only needed to do if we need a higher accuracy value

```
WORKSPACE_DIR=/local/mnt/workspace SDK_VER=1.7.1.12 COMPILE_PRO=yes COMPILE_STD=no DOCKER_OS=ubuntu CK_QAIC_PERCENTILE_CALIBRATION=yes $(ck find repo:ck-qaic)/docker/build.sh bert
```


### Parameters

- `SDK_VER=1.7.1.12`
- `SDK_DIR=/local/mnt/workspace/sdks`
- `WORKSPACE_DIR=/local/mnt/workspace`
- `DOCKER_OS=ubuntu` (only CentOS 7 and Ubuntu 20.04 are supported)
- `PYTHON_VER=3.9.13` (Python interpreter)
- `GCC_MAJOR_VER=11` (C++ compiler)
- `CK_QAIC_PERCENTILE_CALIBRATION=no` (see below)
- `CK_QAIC_PCV=9980` (PCV stands for percentile calibration value, see below)
- `CK_VER=2.6.1` ([MLCommons Collective Knowledge](https://github.com/mlcommons/ck))
- `COMPILE_PRO=yes` (compilation for PCIe Pro server cards)
- `COMPILE_STD=no`  (compilation for PCIe Standard server cards) 
- `DEBUG_BUILD=no` (DEBUG_BUILD=yes builds a larger image with support for model compilation)

**`CK_QAIC_PERCENTILE_CALIBRATION=yes` and `CK_QAIC_PCV=9985` should not be used together**
** `CLEAN_MODEL_BASE=yes` will rebuild the base CK docker container


