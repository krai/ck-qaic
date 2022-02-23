# Benchmarking

## Bert-99

### Edge Category
#### R282_Z93_Q1
##### Quick Accuracy Run
```
ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q1 --sdk=1.6.80 --model=bert-99 \
--mode=accuracy --scenario=offline
```
##### Full Run
```
ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q1 --sdk=1.6.80 --model=bert-99 \
--group.edge --group.closed --offline_target_qps=670 --singlestream_target_latency=11
```

#### R282_Z93_Q5 
##### Quick Accuracy Run
```
ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q5 --sdk=1.6.80 --model=bert-99 \
--mode=accuracy --scenario=offline
```
##### Full Run
```
ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q5 --sdk=1.6.80 --model=bert-99 \
--group.edge --group.closed --offline_target_qps=3280 --singlestream_target_latency=11
```

#### AEDK_15W
##### Quick Accuracy Run
```
ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=aedk_15w --sdk=1.6.80 --model=bert-99 \
--mode=accuracy --scenario=offline
```
##### Full Run
```
ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=aedk_15w --sdk=1.6.80 --model=bert-99 \
--group.edge --group.closed --offline_target_qps=100 --singlestream_target_latency=1
```

#### AEDK_20W
##### Quick Accuracy Run
```
ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=aedk_20w --sdk=1.6.80 --model=bert-99 \
--mode=accuracy --scenario=offline
```
##### Full Run
```
ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=aedk_20w --sdk=1.6.80 --model=bert-99 \
--group.edge --group.closed --offline_target_qps=100 --singlestream_target_latency=1
```

### Datacenter Category
#### R282_Z93_Q8
##### Quick Accuracy Run
```
ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q8 --sdk=1.6.80 --model=bert-99 \
--mode=accuracy --scenario=offline
```
##### Full Run
```
ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q8 --sdk=1.6.80 --model=bert-99 \
--group.datacenter --group.closed --offline_target_qps=5000 --server_target_qps=4900
```

#### G292_Z43_Q16
##### Quick Accuracy Run
```
ck run cmdgen:benchmark.packed-bert --verbose \
--sut=g292_z43_q16 --sdk=1.6.80 --model=bert-99 \
--mode=accuracy --scenario=offline 
```
##### Full Run
```
ck run cmdgen:benchmark.packed-bert --verbose \
--sut=g292_z43_q16 --sdk=1.6.80 --model=bert-99 \
--group.datacenter --group.closed --offline_target_qps=10600 --server_target_qps=10300
```
## Bert-99.9

### Datacenter Category

#### R282_Z93_Q8

##### Quick Accuracy Run
```
ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q8 --sdk=1.6.80 --model=bert-99.9 \
--mode=accuracy --scenario=offline
```
##### Full Run
```
ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q8 --sdk=1.6.80 --model=bert-99.9 \
--group.datacenter --group.closed --offline_target_qps=2500 --server_target_qps=2300
```

#### G292_Z43_Q16
##### Quick Accuracy Run
```
ck run cmdgen:benchmark.packed-bert --verbose \
--sut=g292_z43_q16 --sdk=1.6.80 --model=bert-99.9 \
--mode=accuracy --scenario=offline 
```
##### Full Run
```
ck run cmdgen:benchmark.packed-bert --verbose \
--sut=g292_z43_q16 --sdk=1.6.80 --model=bert-99.9 \
--group.datacenter --group.closed --offline_target_qps=5300 --server_target_qps=4900
```
