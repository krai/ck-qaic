# Qualcomm Cloud AI - MLPerf BERT Docker image

## Docker Build

### With default Percentile Calibration Value
```
SDK_VER=1.6.80 SDK_DIR=/local/mnt/workspace/mlcommons/sdks $(ck find repo:ck-qaic)/docker/build.sh bert
```

### With Exploration of Percentile Calibration Values 
Only needed to do if we need a higher accuracy value

```
CK_QAIC_PERCENTILE_CALIBRATION=yes SDK_VER=1.6.80 SDK_DIR=/local/mnt/workspace/mlcommons/sdks $(ck find repo:ck-qaic)/docker/build.sh bert
```


### Parameters

- `DOCKER_OS=centos7`
- `SDK_VER=1.6.80`
- `SDK_DIR=/local/mnt/workspace/mlcommons/sdks`
- `CK_QAIC_CHECKOUT=main`
- `DEBUG_BUILD=no` (if we need to recompile model binary in the docker container) 
- `CK_QAIC_PERCENTILE_CALIBRATION=no`
- `CK_QAIC_PCV=9985`
- `CLEAN_MODEL_BASE=yes`
- `...`


**`CK_QAIC_PERCENTILE_CALIBRATION=yes` and `CK_QAIC_PCV=9985` should not be used together**
** `CLEAN_MODEL_BASE=yes` will rebuild the base CK docker container

### Building only the base CK Image

This image is independent of SDK and is automatically created by the Docker build of the main image
```
$(ck find repo:ck-qaic)/docker/build_ck.sh bert
```

## Run Options

* `--power` adds power measurement to the experiment run
* `--group.edge` runs two scenarios: `--scenario=offline` and `--scenario=singlestream`
* `--group.datacenter` runs two scenarios: `--scenario=offline` and `--scenario=server`
* `--group.open` runs the following modes: `--mode=accuracy` and `--mode=performance`
* `--group.closed` runs the modes for `--group.open` and in addition the following compliance tests: `--compilance,=TEST01,TEST05`

**We can run individual experiments by using the individual scenario/mode instead of the `group` option**


## Load the container
```
CONTAINER_ID=`ck run cmdgen:benchmark.packed-bert.qaic-loadgen --docker=container_only --out=none \ 
--sdk=1.6.80 --model_name=bert`
```
To see experiments outside of container (--experiment_dir):

```
CONTAINER_ID=`ck run cmdgen:benchmark.packed-bert.qaic-loadgen --docker=container_only --out=none \ 
--sdk=1.5.9 --model_name=bert --experiment_dir`
```

## Quick Accuracy Check

```
ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q1 --sdk=1.6.80 --model=bert-99 \
--mode=accuracy --scenario=offline --target_qps=650 \
--container=$CONTAINER_ID
```

## SUTs

### `r282_z93_q1`

```
ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q1 --sdk=1.6.80 --model=bert-99 \
--group.edge --group.closed --offline_override_batch_size=4096 --offline_target_qps=650 \
--target_latency=11 --container=$CONTAINER_ID
```

### `r282_z93_q5`

```
ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q1 --sdk=1.6.80 --model=bert-99 \
--group.edge --group.closed --offline_override_batch_size=4096 \
--offline_target_qps=3200 --target_latency=11 --container=$CONTAINER_ID
```

### `r282_z93_q8`


```
ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q8 --sdk=1.6.80 --model=bert-99 \
--group.edge --group.closed --offline_override_batch_size=4096 --server_override_batch_size=512 \
--offline_target_qps=5201 --server_target_qps=4901 --max_wait=10000 \
--container=$CONTAINER_ID
```

```
ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q8 --sdk=1.5.9 --model=bert-99.9 \
--group.edge --group.closed --offline_override_batch_size=4096 --server_override_batch_size=1024 \
--offline_target_qps=2700 --server_target_qps=2250 --max_wait=50000 \
--container=$CONTAINER_ID
```

### `g292_z43_q16`

```
ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=g292_z43_q16 --sdk=1.6.80 --model=bert-99 \
--group.datacenter --group.closed --offline_override_batch_size=4096 --server_override_batch_size=1024 \
--offline_target_qps=10600 --server_target_qps=10301 --max_wait=10000 \
--container=$CONTAINER_ID
```

```
ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=g292_z43_q16 --sdk=1.6.80 --model=bert-99.9 \
--group.datacenter --group.closed --offline_override_batch_size=4096 --server_override_batch_size=1024 \
--offline_target_qps=5520 --server_target_qps=5100 --max_wait=50000 \
--container=$CONTAINER_ID
```

## --docker option

`--docker` allows to load the container and use it. 

When `--docker=container_only` or `--docker` are set the following optional parameters can be used:


`--experiment_dir` - directory with experimental data (`${CK_EXPERIMENT_DIR}`by default)

`--volume <experiment_dir_default>:<docker_experiment_dir_default>` - map directory in docker to directory in local machine

`--docker_experiment_dir_default`  - `/home/krai/CK_REPOS/local/experiment` by default

`--experiment_dir_default`  - `${CK_EXPERIMENT_DIR}` by default
 
`--docker_image`   - `krai/mlperf.<model_name>.centos7:<sdk>` by default

`<model_name>` - `bert`      

`<sdk>` - for example, `1.6.80`

`--shared_group_name` - `qaic` by default
