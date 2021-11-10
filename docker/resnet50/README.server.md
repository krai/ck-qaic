# Qualcomm Cloud AI - MLPerf ResNet50 Docker image

## Benchmark

## Load the container
```
CONTAINER_ID=`ck run cmdgen:benchmark.image-classification.qaic-loadgen  --docker=container_only --out=none \ 
--sdk=1.5.6 --model_name=resnet50`
```

To see experiments outside of container (--experiment_dir):

```
CONTAINER_ID=`ck run cmdgen:benchmark.image-classification.qaic-loadgen --docker=container_only --out=none \ 
--sdk=1.5.6 --model_name=resnet50 --experiment_dir`
```
### Server

#### Accuracy

##### `r282_z93_q8`

```
ck run cmdgen:benchmark.image-classification.qaic-loadgen --verbose \
--sut=r282_z93_q8 --sdk=1.5.6 --model=resnet50 \
--mode=accuracy --scenario=server --target_qps=156666 --container=$CONTAINER_ID
```

##### `g292_z43_q16`

```
ck run cmdgen:benchmark.image-classification.qaic-loadgen --verbose \
--sut=g292_z43_q16 --sdk=1.5.6 --model=resnet50 \
--mode=accuracy --scenario=server --target_qps=313333 --container=$CONTAINER_ID
```

#### Performance

##### `r282_z93_q8`

```
ck run cmdgen:benchmark.image-classification.qaic-loadgen --verbose \
--sut=r282_z93_q8 --sdk=1.5.6 --model=resnet50 \
--mode=performance --scenario=server --target_qps=16666 --container=$CONTAINER_ID
```

##### `g292_z43_q16`

```
ck run cmdgen:benchmark.image-classification.qaic-loadgen --verbose \
--sut=g292_z43_q16 --sdk=1.5.6 --model=resnet50 \
--mode=performance --scenario=server --target_qps=33333 --container=$CONTAINER_ID
```

#### Power (full)

##### `r282_z93_q8`

```
ck run cmdgen:benchmark.image-classification.qaic-loadgen --verbose \
--sut=r282_z93_q8 --sdk=1.5.6 --model=resnet50 \
--mode=performance --scenario=server --target_qps=133133 \
--power=yes --power_server_ip=10.222.154.58 --power_server_port=4959 --container=$CONTAINER_ID
```

##### `g292_z43_q16`

```
ck run cmdgen:benchmark.image-classification.qaic-loadgen --verbose \
--sut=g292_z43_q16 --sdk=1.5.6 --model=resnet50 \
--mode=performance --scenario=server --target_qps=310000 \
--power=yes --power_server_ip=10.222.147.109 --power_server_port=4953 --container=$CONTAINER_ID
```
## --docker option

`--docker` allows to load the container and use it. 

```
ck run cmdgen:benchmark.image-classification.qaic-loadgen --verbose \
--sut=g292_z43_q16 --sdk=1.5.6 --model=resnet50 \
--mode=performance --scenario=server --target_qps=310000 \
--power=yes --power_server_ip=10.222.147.109 --power_server_port=4953 --docker --experiment_dir
```

When `--docker=container_only` or `--docker` are set the following optional parameters can be used:


`--experiment_dir` - directory with experimental data (`${CK_EXPERIMENT_DIR}`by default)

`--volume <experiment_dir_default>:<docker_experiment_dir_default>` - map directory in docker to directory in local machine

`--docker_experiment_dir_default`  - `/home/krai/CK_REPOS/local/experiment` by default

` --experiment_dir_default`  - `${CK_EXPERIMENT_DIR}` by default
 
`--docker_image`   - `krai/mlperf.<model_name>.centos7:<sdk>` by default

`<model_name>` - `resnet50`      

`<sdk>` - for example, `1.5.6`

`--shared_group_name` - `qaic` by default
