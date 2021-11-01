# Qualcomm Cloud AI - MLPerf SSD-ResNet34 Docker image

## Build

```
$(ck find ck-qaic:docker:ssd-resnet34)/build.sh
```

### Build parameters

- `SDK_VER=1.5.6`
- `DOCKER_OS=centos7`
- CK_QAIC_CHECKOUT=159e6e903e75879c7f3c7551c4e03f7caf61d569
- `CK_QAIC_PERCENTILE_CALIBRATION=no`
- `CK_QAIC_PCV=9985`
- `...`

**`CK_QAIC_PERCENTILE_CALIBRATION=no` and `CK_QAIC_PCV=9985` should not be used together**
