# SSD-MobileNet Docker image

## Benchmark

### Load the container
```
CONTAINER_ID=`ck run cmdgen:benchmark.object-detection.qaic-loadgen --docker=container_only --out=none \ 
--sdk=1.5.6 --model_name=ssd-mobilenet`
```
To see experiments outside of container (--experiment_dir):

```
CONTAINER_ID=`ck run cmdgen:benchmark.object-detection.qaic-loadgen --docker=container_only --out=none \ 
--sdk=1.5.6 --model_name=ssd-mobilenet --experiment_dir`
```
#### Optional parameters

When `--docker=container_only` or `--docker` are set the following optional parameters can be used:


`--experiment_dir` - directory with experimental data (`${CK_EXPERIMENT_DIR}`by default)

`--volume <experiment_dir_default>:<docker_experiment_dir_default>` - map directory in docker to directory in local machine

`--docker_experiment_dir_default`  - `/home/krai/CK_REPOS/local/experiment` by default

` --experiment_dir_default`  - `${CK_EXPERIMENT_DIR}` by default
 
`--docker_image`   - `krai/mlperf.<model_name>.centos7:<sdk>` by default

`<model_name>` - `ssd-mobilenet`      

`<sdk>` - for example, `1.5.6`

`--shared_group_name` - `qaic` by default


### Offline

#### Accuracy

##### `r282_z93_q1`

```
ck run cmdgen:benchmark.object-detection.qaic-loadgen --verbose \
--sut=r282_z93_q1 --sdk=1.5.6 --model=ssd_mobilenet \
--mode=accuracy --scenario=offline --target_qps=19500 --container=$CONTAINER_ID
```

##### `r282_z93_q5`

```
ck run cmdgen:benchmark.object-detection.qaic-loadgen --verbose \
--sut=r282_z93_q5 --sdk=1.5.6 --model=ssd_mobilenet \
--mode=accuracy --scenario=offline --target_qps=97500 --container=$CONTAINER_ID
```

#### Performance

##### `r282_z93_q1`

```
ck run cmdgen:benchmark.object-detection.qaic-loadgen --verbose \
--sut=r282_z93_q1 --sdk=1.5.6 --model=ssd_mobilenet \
--mode=performance --scenario=offline --target_qps=19500 --container=$CONTAINER_ID
```

##### `r282_z93_q5` [optional]

```
ck run cmdgen:benchmark.object-detection.qaic-loadgen --verbose \
--sut=r282_z93_q5 --sdk=1.5.6 --model=ssd_mobilenet \
--mode=performance --scenario=offline --target_qps=97500 --container=$CONTAINER_ID
```

#### Power

##### `r282_z93_q1` [optional]

```
ck run cmdgen:benchmark.object-detection.qaic-loadgen --verbose \
--sut=r282_z93_q1 --sdk=1.5.6 --model=ssd_mobilenet \
--mode=performance --scenario=offline --target_qps=19500 \
--power=yes --power_server_ip=10.222.154.58 --power_server_port=4956 --container=$CONTAINER_ID
```

##### `r282_z93_q5`

```
ck run cmdgen:benchmark.object-detection.qaic-loadgen --verbose \
--sut=r282_z93_q5 --sdk=1.5.6 --model=ssd_mobilenet \
--mode=performance --scenario=offline --target_qps=97500 \
--power=yes --power_server_ip=10.222.154.58 --power_server_port=4956 --container=$CONTAINER_ID
```
