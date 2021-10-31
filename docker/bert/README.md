# Qualcomm Cloud AI - MLPerf BERT Docker image
## With Exploration of Percentile Calibration Values
```
CK_QAIC_PERCENTILE_CALIBRATION=yes $(ck find ck-qaic:docker:bert)/build.sh
```
## With default Percentile Calibration Value
```
$(ck find ck-qaic:docker:bert)/build.sh
```

## Parameters

- `DOCKER_OS=centos7`
- `SDK_VER=1.5.9`
- `CK_QAIC_BRANCH=main`
- `...`
