# Benchmarking

## Edge Category
### R282_Z93_Q1

#### Quick Accuracy Run
```
ck run cmdgen:benchmark.image-classification.qaic-loadgen --verbose \
--sut=r282_z93_q1 --sdk=1.6.80 --model=resnet50 \
--mode=accuracy --scenario=offline 
```
#### Full Run
```
ck run cmdgen:benchmark.image-classification.qaic-loadgen --verbose \
--sut=r282_z93_q1 --sdk=1.6.80 --model=resnet50 \
--group.edge --group.closed --offline_target_qps=22222 \ --singlestream_target_latency=1.5 --multistream_target_latency=12
```

### R282_Z93_Q5 
#### Quick Accuracy Run
```
ck run cmdgen:benchmark.image-classification.qaic-loadgen --verbose \
--sut=r282_z93_q5 --sdk=1.6.80 --model=resnet50 \
--mode=accuracy --scenario=offline
```
#### Full Run
```
ck run cmdgen:benchmark.image-classification.qaic-loadgen --verbose \
--sut=r282_z93_q5 --sdk=1.6.80 --model=resnet50 \
--group.edge --group.closed --offline_target_qps=107000 \ --singlestream_target_latency=1.5 --multistream_target_latency=12
```

### AEDK_15W
#### Quick Accuracy Run
```
ck run cmdgen:benchmark.image-classification.qaic-loadgen --verbose \
--sut=aedk_15w --sdk=1.6.80 --model=resnet50 \
--mode=accuracy --scenario=offline 
```
#### Full Run
```
ck run cmdgen:benchmark.image-classification.qaic-loadgen --verbose \
--sut=aedk_15w --sdk=1.6.80 --model=resnet50 \
--group.edge --group.closed --offline_target_qps=5500 \ --singlestream_target_latency=1.5 --multistream_target_latency=12
```

### AEDK_20W
#### Quick Accuracy Run
```
ck run cmdgen:benchmark.image-classification.qaic-loadgen --verbose \
--sut=aedk_20w --sdk=1.6.80 --model=resnet50 \
--mode=accuracy --scenario=offline
```
#### Full Run
```
ck run cmdgen:benchmark.image-classification.qaic-loadgen --verbose \
--sut=aedk_20w --sdk=1.6.80 --model=resnet50 \
--group.edge --group.closed --offline_target_qps=9000 \ --singlestream_target_latency=1.5 --multistream_target_latency=12
```

## Datacenter Category
### R282_Z93_Q8
#### Quick Accuracy Run
```
ck run cmdgen:benchmark.image-classification.qaic-loadgen --verbose \
--sut=r282_z93_q8 --sdk=1.6.80 --model=resnet50 \
--mode=accuracy --scenario=offline
```
#### Full Run
```
ck run cmdgen:benchmark.image-classification.qaic-loadgen --verbose \
--sut=r282_z93_q8 --sdk=1.6.80 --model=resnet50 \
--group.edge --group.closed --offline_target_qps=169000 \ --server_target_qps=144000
```

### G292_Z43_Q16
#### Quick Accuracy Run
```
ck run cmdgen:benchmark.image-classification.qaic-loadgen --verbose \
--sut=g292_z43_q16 --sdk=1.6.80 --model=resnet50 \
--mode=accuracy --scenario=offline 
```
#### Full Run
```
ck run cmdgen:benchmark.image-classification.qaic-loadgen --verbose \
--sut=g292_z43_q16 --sdk=1.6.80 --model=resnet50 \
--group.edge --group.closed --offline_target_qps=340000 \ --server_target_qps=310000
```
