# Qualcomm Cloud AI - MLPerf BERT Docker image

## Benchmark

### Server

#### Accuracy

##### `r282_z93_q8`

###### precision mixed

```
docker run --privileged \
--user=krai:kraig --group-add $(cut -d: -f3 < <(getent group qaic)) \
--volume ${CK_EXPERIMENTS}:/home/krai/CK_REPOS/local/experiment \
--rm krai/mlperf.bert.centos7:1.5.9 \
"ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q8 --sdk=1.5.9 --model=bert-99 \
--mode=accuracy --scenario=server --override_batch_size=512 \
--target_qps=4901 --max_wait=10000"
```

###### precision fp16

```
docker run --privileged \
--user=krai:kraig --group-add $(cut -d: -f3 < <(getent group qaic)) \
--volume ${CK_EXPERIMENTS}:/home/krai/CK_REPOS/local/experiment \
--rm krai/mlperf.bert.centos7:1.5.9 \
"ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q8 --sdk=1.5.9 --model=bert-99.9 \
--mode=accuracy --scenario=server --override_batch_size=512 \
--target_qps=2500 --max_wait=50000"
```

##### `g292_z43_q16`

###### precision mixed

```
docker run --privileged \
--user=krai:kraig --group-add $(cut -d: -f3 < <(getent group qaic)) \
--volume ${CK_EXPERIMENTS}:/home/krai/CK_REPOS/local/experiment \
--rm krai/mlperf.bert.centos7:1.5.9 \
"ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=g292_z43_q16 --sdk=1.5.9 --model=bert-99 \
--mode=accuracy --scenario=server --override_batch_size=512 \
--target_qps=10300 --max_wait=10000"
```

###### precision fp16

```
docker run --privileged \
--user=krai:kraig --group-add $(cut -d: -f3 < <(getent group qaic)) \
--volume ${CK_EXPERIMENTS}:/home/krai/CK_REPOS/local/experiment \
--rm krai/mlperf.bert.centos7:1.5.9 \
"ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=g292_z43_q16 --sdk=1.5.9 --model=bert-99.9 \
--mode=accuracy --scenario=server --override_batch_size=512 \
--target_qps=5000 --max_wait=50000"
```

#### Performance

##### `r282_z93_q8` [optional]

###### precision mixed

```
docker run --privileged \
--user=krai:kraig --group-add $(cut -d: -f3 < <(getent group qaic)) \
--volume ${CK_EXPERIMENTS}:/home/krai/CK_REPOS/local/experiment \
--rm krai/mlperf.bert.centos7:1.5.9 \
"ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q8 --sdk=1.5.9 --model=bert-99 \
--mode=performance --scenario=server --override_batch_size=512 \
--target_qps=4901 --max_wait=10000"
```

###### precision fp16

```
docker run --privileged \
--user=krai:kraig --group-add $(cut -d: -f3 < <(getent group qaic)) \
--volume ${CK_EXPERIMENTS}:/home/krai/CK_REPOS/local/experiment \
--rm krai/mlperf.bert.centos7:1.5.9 \
"ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q8 --sdk=1.5.9 --model=bert-99.9 \
--mode=performance --scenario=server --override_batch_size=1024 \
--target_qps=2250 --max_wait=50000"
```

##### `g292_z43_q16` [optional]

###### precision mixed

```
docker run --privileged \
--user=krai:kraig --group-add $(cut -d: -f3 < <(getent group qaic)) \
--volume ${CK_EXPERIMENTS}:/home/krai/CK_REPOS/local/experiment \
--rm krai/mlperf.bert.centos7:1.5.9 \
"ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=g292_z43_q16 --sdk=1.5.9 --model=bert-99 \
--mode=performance --scenario=server --override_batch_size=512 \
--target_qps=10301 --max_wait=10000"
```

###### precision fp16

```
docker run --privileged \
--user=krai:kraig --group-add $(cut -d: -f3 < <(getent group qaic)) \
--volume ${CK_EXPERIMENTS}:/home/krai/CK_REPOS/local/experiment \
--rm krai/mlperf.bert.centos7:1.5.9 \
"ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=g292_z43_q16 --sdk=1.5.9 --model=bert-99.9 \
--mode=performance --scenario=server --override_batch_size=256 \
--target_qps=5100 --max_wait=50000"
```

#### Power

##### `r282_z93_q8`

###### precision mixed

```
docker run --privileged \
--user=krai:kraig --group-add $(cut -d: -f3 < <(getent group qaic)) \
--volume ${CK_EXPERIMENTS}:/home/krai/CK_REPOS/local/experiment \
--rm krai/mlperf.bert.centos7:1.5.9 \
"ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q8 --sdk=1.5.9 --model=bert-99 \
--mode=performance --scenario=server --override_batch_size=512 \
--target_qps=4901 --max_wait=10000 \
--power=yes --power_server_ip=10.222.154.58 --power_server_port=4959"
```

###### precision fp16

```
docker run --privileged \
--user=krai:kraig --group-add $(cut -d: -f3 < <(getent group qaic)) \
--volume ${CK_EXPERIMENTS}:/home/krai/CK_REPOS/local/experiment \
--rm krai/mlperf.bert.centos7:1.5.9 \
"ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q8 --sdk=1.5.9 --model=bert-99.9 \
--mode=performance --scenario=server --override_batch_size=1024 \
--target_qps=2250 -- max_wait=50000 \
--power=yes --power_server_ip=10.222.154.58 --power_server_port=4959"
```

##### `g292_z43_q16`

###### precision mixed

```
docker run --privileged \
--user=krai:kraig --group-add $(cut -d: -f3 < <(getent group qaic)) \
--volume ${CK_EXPERIMENTS}:/home/krai/CK_REPOS/local/experiment \
--rm krai/mlperf.bert.centos7:1.5.9 \
"ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=g292_z43_q16 --sdk=1.5.9 --model=bert-99 \
--mode=performance --scenario=server --override_batch_size=512 \
--target_qps=10301 --max_wait=10000 \
--power=yes --power_server_ip=10.222.147.109 --power_server_port=4953"
```

###### precision fp16

```
docker run --privileged \
--user=krai:kraig --group-add $(cut -d: -f3 < <(getent group qaic)) \
--volume ${CK_EXPERIMENTS}:/home/krai/CK_REPOS/local/experiment \
--rm krai/mlperf.bert.centos7:1.5.9 \
"ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=g292_z43_q16 --sdk=1.5.9 --model=bert-99.9 \
--mode=performance --scenario=server --override_batch_size=256 \
--target_qps=5100 --max_wait=50000 \
--power=yes --power_server_ip=10.222.147.109 --power_server_port=4953"
```
