# Qualcomm Cloud AI - MLPerf ResNet50 Docker image

## Build

```
$(ck find repo:ck-qaic)/docker/build.sh resnet50
```

### Build parameters

- `SDK_VER=1.5.6`
- `DOCKER_OS=centos7`
- `CK_QAIC_CHECKOUT=4eb006cd7af97ee281f073a5e17f790255143ed7`
- `CK_QAIC_PERCENTILE_CALIBRATION=no`
- `CK_QAIC_PCV=9985`
- `...`

**`CK_QAIC_PERCENTILE_CALIBRATION=yes` and `CK_QAIC_PCV=9985` should not be used together**

## Run Options

* `--power` adds power measurement to the experiment run
* `--group.edge` runs two scenarios: `--scenario=offline` and `--scenario=singlestream`
* `--group.datacenter` runs two scenarios: `--scenario=offline` and `--scenario=server`
* `--group.open` runs the following modes: `--mode=accuracy` and `--mode=performance`
* `--group.closed` runs the modes for `--group.open` and in addition the following compliance tests: `--compilance,=TEST01,TEST04-A,TEST04-B,TEST05`

**We can run individual experiments by using the individual scenario/mode instead of the `group` option**


## Load the container
```
CONTAINER_ID=`ck run cmdgen:benchmark.image-classification.qaic-loadgen  --docker=container_only --out=none`
```

### `r282_z93_q1`

```
ck run cmdgen:benchmark.image-classification.qaic-loadgen --verbose \
--sut=r282_z93_q1 --sdk=1.5.6 --model=resnet50 \
--group.edge --group.closed --target_qps=22222 --target_latency=1.5 \
--container=$CONTAINER_ID
```

### `r282_z93_q5`

```
ck run cmdgen:benchmark.image-classification.qaic-loadgen --verbose \
--sut=r282_z93_q5 --sdk=1.5.6 --model=resnet50 \
--group.edge --group.closed --target_qps=111111 --target_latency=1.5 \
--container=$CONTAINER_ID
```

### `r282_z93_q8`

```
ck run cmdgen:benchmark.image-classification.qaic-loadgen --verbose \
--sut=r282_z93_q8 --sdk=1.5.6 --model=resnet50 \
--group.datacenter --group.closed --target_qps=166666 --server_target_qps=145000 \
--container=$CONTAINER_ID --power
```

### `g292_z43_q16`

```
ck run cmdgen:benchmark.image-classification.qaic-loadgen --verbose \
--sut=g292_z43_q16 --sdk=1.5.6 --model=resnet50 \
--group.datacenter --group.closed --target_qps=333333 --server_target_qps=310000 \
--container=$CONTAINER_ID --power
```
