# Qualcomm Cloud AI - MLPerf BERT Docker image

## Benchmark

### Load the container
```
CONTAINER_ID=`docker run -dt --privileged \
--user=krai:kraig --group-add $(cut -d: -f3 < <(getent group qaic)) \
--volume ${CK_EXPERIMENT_DIR}:/home/krai/CK_REPOS/local/experiment \
--rm krai/mlperf.bert.centos7:1.5.9`
```
To see experiments outside of container (--experiment_dir):

```
CONTAINER_ID=`docker run -dt --privileged \
--user=krai:kraig --group-add $(cut -d: -f3 < <(getent group qaic)) \
--volume ${CK_EXPERIMENT_DIR}:/home/krai/CK_REPOS/local/experiment \
--rm krai/mlperf.bert.centos7:1.5.9 --experiment_dir`
```

### Offline

#### Accuracy

##### `r282_z93_q1`

###### precision mixed

```
ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q1 --sdk=1.5.9 --model=bert-99 \
--mode=accuracy --scenario=offline --override_batch_size=4096 --target_qps=600 --container=$CONTAINER_ID
```

##### `r282_z93_q5`


###### precision mixed

```
ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q5 --sdk=1.5.9 --model=bert-99 \
--mode=accuracy --scenario=offline --override_batch_size=1024 --target_qps=1700 --container=$CONTAINER_ID
```

##### `r282_z93_q8`

###### precision mixed

```
ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q8 --sdk=1.5.9 --model=bert-99 \
--mode=accuracy --scenario=offline --override_batch_size=4096 --target_qps=5200 --container=$CONTAINER_ID
```

###### precision fp16

```
ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q8 --sdk=1.5.9 --model=bert-99.9 \
--mode=accuracy --scenario=offline --override_batch_size=1024 --target_qps=2700 --container=$CONTAINER_ID
```

##### `g292_z43_q16`

###### precision mixed

```
ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=g292_z43_q16 --sdk=1.5.9 --model=bert-99 \
--mode=accuracy --scenario=offline --override_batch_size=4096 --target_qps=10600 --container=$CONTAINER_ID
```


###### precision fp16

```
ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=g292_z43_q16 --sdk=1.5.9 --model=bert-99.9 \
--mode=accuracy --scenario=offline --override_batch_size=4096 --target_qps=5000 --container=$CONTAINER_ID
```

#### Performance

##### `r282_z93_q1`

###### precision mixed
```
ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q1 --sdk=1.5.9 --model=bert-99 \
--mode=performance --scenario=offline --override_batch_size=4096 --target_qps=650 --container=$CONTAINER_ID
```


##### `r282_z93_q5`

###### precision mixed

```
ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q5 --sdk=1.5.9 --model=bert-99 \
--mode=performance --scenario=offline --override_batch_size=1024 --target_qps=3200 --container=$CONTAINER_ID
```


##### `r282_z93_q8` [optional]


###### precision mixed

```
ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q8 --sdk=1.5.9 --model=bert-99 \
--mode=performance --scenario=offline --override_batch_size=512 --target_qps=5201 --container=$CONTAINER_ID
```

###### precision fp16
```
ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q8 --sdk=1.5.9 --model=bert-99.9 \
--mode=performance --scenario=offline --override_batch_size=1024 --target_qps=2700 --container=$CONTAINER_ID
```

##### `g292_z43_q16` [optional]

###### precision mixed

```
ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=g292_z43_q16 --sdk=1.5.9 --model=bert-99 \
--mode=performance --scenario=offline --override_batch_size=4096 --target_qps=10600 --container=$CONTAINER_ID
```

###### precision fp16
```
ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=g292_z43_q16 --sdk=1.5.9 --model=bert-99.9 \
--mode=performance --scenario=offline --override_batch_size=1024 --target_qps=5520 --container=$CONTAINER_ID
```

#### Power

##### `r282_z93_q1` [optional]

###### precision mixed

```
ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q1 --sdk=1.5.9 --model=bert-99 \
--mode=performance --scenario=offline --override_batch_size=4096 --target_qps=650 \
--power=yes --power_server_ip=10.222.154.58 --power_server_port=4956 --container=$CONTAINER_ID
```

##### `r282_z93_q5` [optional]

###### precision mixed

```
ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q5 --sdk=1.5.9 --model=bert-99 \
--mode=performance --scenario=offline --override_batch_size=1024 --target_qps=3200 \
--power=yes --power_server_ip=10.222.154.58 --power_server_port=4956 --container=$CONTAINER_ID
```

##### `r282_z93_q8`

###### precision mixed

```
ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q8 --sdk=1.5.9 --model=bert-99 \
--mode=performance --scenario=offline --override_batch_size=512 --target_qps=5201 \
--power=yes --power_server_ip=10.222.154.58 --power_server_port=4959 --container=$CONTAINER_ID
```

###### precision fp16
```
ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q8 --sdk=1.5.9 --model=bert-99.9 \
--mode=performance --scenario=offline --override_batch_size=1024 --target_qps=2700 \
--power=yes --power_server_ip=10.222.154.58 --power_server_port=4959 --container=$CONTAINER_ID
```

##### `g292_z43_q16`

###### precision mixed

```
ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=g292_z43_q16 --sdk=1.5.9 --model=bert-99 \
--mode=performance --scenario=offline --override_batch_size=4096 --target_qps=10600 \
--power=yes --power_server_ip=10.222.147.109 --power_server_port=4953 --container=$CONTAINER_ID
```

###### precision fp16
```
ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=g292_z43_q16 --sdk=1.5.9 --model=bert-99.9 \
--mode=performance --scenario=offline --override_batch_size=1024 --target_qps=5520 \
--power=yes --power_server_ip=10.222.147.109 --power_server_port=4953 --container=$CONTAINER_ID
```
