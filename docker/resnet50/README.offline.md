# Qualcomm Cloud AI - MLPerf ResNet50 Docker image

## Benchmark

## Load the container
```
CONTAINER_ID=`ck run cmdgen:benchmark.image-classification.qaic-loadgen  --docker=container_only --out=none`
```

### Offline

#### Accuracy

##### `r282_z93_q1`

```
ck run cmdgen:benchmark.image-classification.qaic-loadgen --verbose \
--sut=r282_z93_q1 --sdk=1.5.6 --model=resnet50 \
--mode=accuracy --scenario=offline --target_qps=22222 \
--container=$CONTAINER_ID
```

##### `r282_z93_q5`

```
ck run cmdgen:benchmark.image-classification.qaic-loadgen --verbose \
--sut=r282_z93_q5 --sdk=1.5.6 --model=resnet50 \
--mode=accuracy --scenario=offline --target_qps=111111 \
--container=$CONTAINER_ID
```

##### `r282_z93_q8`

```
ck run cmdgen:benchmark.image-classification.qaic-loadgen --verbose \
--sut=r282_z93_q8 --sdk=1.5.6 --model=resnet50 \
--mode=accuracy --scenario=offline --target_qps=166666 \
--container=$CONTAINER_ID
```

##### `g292_z43_q16`

```
ck run cmdgen:benchmark.image-classification.qaic-loadgen --verbose \
--sut=g292_z43_q16 --sdk=1.5.6 --model=resnet50 \
--mode=accuracy --scenario=offline --target_qps=333333 \
--container=$CONTAINER_ID
```

#### Performance

##### `r282_z93_q1`

```
ck run cmdgen:benchmark.image-classification.qaic-loadgen --verbose \
--sut=r282_z93_q1 --sdk=1.5.6 --model=resnet50 \
--mode=performance --scenario=offline --target_qps=22222 \
--container=$CONTAINER_ID
```

##### `r282_z93_q5` [optional]

```
ck run cmdgen:benchmark.image-classification.qaic-loadgen --verbose \
--sut=r282_z93_q5 --sdk=1.5.6 --model=resnet50 \
--mode=performance --scenario=offline --target_qps=111111 \
--container=$CONTAINER_ID
```

##### `r282_z93_q8` [optional]

```
ck run cmdgen:benchmark.image-classification.qaic-loadgen --verbose \
--sut=r282_z93_q8 --sdk=1.5.6 --model=resnet50 \
--mode=performance --scenario=offline --target_qps=166666 \
--container=$CONTAINER_ID
```

##### `g292_z43_q16` [optional]

```
ck run cmdgen:benchmark.image-classification.qaic-loadgen --verbose \
--sut=g292_z43_q16 --sdk=1.5.6 --model=resnet50 \
--mode=performance --scenario=offline --target_qps=333333 \
--container=$CONTAINER_ID
```

#### Power

##### `r282_z93_q1` [optional]

```
ck run cmdgen:benchmark.image-classification.qaic-loadgen --verbose \
--sut=r282_z93_q1 --sdk=1.5.6 --model=resnet50 \
--mode=performance --scenario=offline --target_qps=22222 \
--power=yes --power_server_ip=10.222.154.58 --power_server_port=4956 \
--container=$CONTAINER_ID
```

##### `r282_z93_q5`

```
ck run cmdgen:benchmark.image-classification.qaic-loadgen --verbose \
--sut=r282_z93_q5 --sdk=1.5.6 --model=resnet50 \
--mode=performance --scenario=offline --target_qps=111111 \
--power=yes --power_server_ip=10.222.154.58 --power_server_port=4956 \
--container=$CONTAINER_ID
```

##### `r282_z93_q8`

```
ck run cmdgen:benchmark.image-classification.qaic-loadgen --verbose \
--sut=r282_z93_q8 --sdk=1.5.6 --model=resnet50 \
--mode=performance --scenario=offline --target_qps=166666 \
--power=yes --power_server_ip=10.222.154.58 --power_server_port=4959 \
--container=$CONTAINER_ID
```

##### `g292_z43_q16`

```
ck run cmdgen:benchmark.image-classification.qaic-loadgen --verbose \
--sut=g292_z43_q16 --sdk=1.5.6 --model=resnet50 \
--mode=performance --scenario=offline --target_qps=333333 \
--power=yes --power_server_ip=10.222.147.109 --power_server_port=4953 \
--container=$CONTAINER_ID
```
