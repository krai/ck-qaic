# Qualcomm Cloud AI - MLPerf SSD-MobileNet Docker image

## Building the base CK Image

This image is independent of SDK
```
$(ck find repo:ck-qaic)/docker/build_ck.sh ssd-mobilenet
```

## Docker Build

```
$(ck find repo:ck-qaic)/docker/build.sh ssd-mobilenet
```

### Build parameters

- `SDK_VER=1.6.80`
- `DOCKER_OS=centos7`
- `CK_QAIC_CHECKOUT=4eb006cd7af97ee281f073a5e17f790255143ed7`
- `CK_QAIC_PERCENTILE_CALIBRATION=no`
- `CK_QAIC_PCV=9985`
- `CLEAN_MODEL_BASE=yes`
- `...`

**`CK_QAIC_PERCENTILE_CALIBRATION=yes` and `CK_QAIC_PCV=9985` should not be used together**
** `CLEAN_MODEL_BASE=yes` will rebuild the base CK docker container

## Run Options

* `--power` adds power measurement to the experiment run
* `--group.edge` runs two scenarios: `--scenario=offline` and `--scenario=singlestream`
* `--group.open` runs the following modes: `--mode=accuracy` and `--mode=performance`
* `--group.closed` runs the modes for `--group.open` and in addition the following compliance tests: `--compilance,=TEST01,TEST04-A,TEST04-B,TEST05`

**We can run individual experiments by using the individual scenario/mode instead of the `group` option**


## Load the container
```
CONTAINER_ID=`ck run cmdgen:benchmark.object-detection-small.qaic-loadgen --docker=container_only --out=none \
--sdk=1.6.80 --model_name=ssd-mobilenet`
```
To see experiments outside of container (--experiment_dir):

```
CONTAINER_ID=`ck run cmdgen:benchmark.object-detection-small.qaic-loadgen --docker=container_only --out=none \
--sdk=1.6.80 --model_name=ssd-mobilenet --experiment_dir`
```

## Quick Accuracy Check
```
ck run cmdgen:benchmark.object-detection-small.qaic-loadgen --verbose \
--sut=r282_z93_q1 --sdk=1.6.80 --model=ssd_mobilenet \
--mode=accuracy --scenario=offline --target_qps=19500 \
--container=$CONTAINER_ID
```

## SUTs

### `r282_z93_q1`

```
ck run cmdgen:benchmark.object-detection-small.qaic-loadgen --verbose \
--sut=r282_z93_q1 --sdk=1.6.80 --model=ssd_mobilenet \
--group.edge --group.closed --target_qps=19500 --target_latency=1 \
--container=$CONTAINER_ID
```

### `r282_z93_q5`

```
ck run cmdgen:benchmark.object-detection-small.qaic-loadgen --verbose \
--sut=r282_z93_q5 --sdk=1.6.80 --model=ssd_mobilenet \
--group.edge --group.closed --target_qps=97500 --target_latency=1 \
--container=$CONTAINER_ID --power
```

## --docker option

`--docker` allows to load the container and use it. 

```
ck run cmdgen:benchmark.object-detection-small.qaic-loadgen --verbose \
--sut=r282_z93_q5 --sdk=1.6.80 --model=ssd-mobilenet --mode=accuracy \
--scenario=offline --target_qps=97500 --docker --experiment_dir
```

When `--docker=container_only` or `--docker` are set the following optional parameters can be used:


`--experiment_dir` - directory with experimental data (`${CK_EXPERIMENT_DIR}`by default)

`--volume <experiment_dir_default>:<docker_experiment_dir_default>` - map directory in docker to directory in local machine

`--docker_experiment_dir_default`  - `/home/krai/CK_REPOS/local/experiment` by default

` --experiment_dir_default`  - `${CK_EXPERIMENT_DIR}` by default
 
`--docker_image`   - `krai/mlperf.<model_name>.centos7:<sdk>` by default

`<model_name>` - `ssd-mobilenet`      

`<sdk>` - for example, `1.6.80`

`--shared_group_name` - `qaic` by default
