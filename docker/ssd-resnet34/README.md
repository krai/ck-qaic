# Qualcomm Cloud AI - MLPerf SSD-ResNet34 Docker image

## Build

```
$(ck find repo:ck-qaic)/docker/build.sh ssd-resnet34
```

### Build parameters

- `SDK_VER=1.5.6`
- `DOCKER_OS=centos7`
- `CK_QAIC_CHECKOUT=4eb006cd7af97ee281f073a5e17f790255143ed7`
- `CK_QAIC_PERCENTILE_CALIBRATION=no`
- `CK_QAIC_PCV=9985`
- `...`

**`CK_QAIC_PERCENTILE_CALIBRATION=no` and `CK_QAIC_PCV=9985` should not be used together**
