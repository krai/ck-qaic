# Benchmarking

## Edge Category
### R282_Z93_Q1

#### Quick Accuracy Run
```
ck run cmdgen:benchmark.object-detection-large.qaic-loadgen --verbose \
--sut=r282_z93_q1 --sdk=1.6.80 --model=ssd_resnet34 \
--mode=accuracy --scenario=offline 
```
#### Full Run
```
ck run cmdgen:benchmark.object-detection-large.qaic-loadgen --verbose \
--sut=r282_z93_q1 --sdk=1.6.80 --model=ssd_resnet34 \
--group.edge --group.closed --offline_target_qps=435 --singlestream_target_latency=40 --multistream_target_latency=320
```

### R282_Z93_Q5 
#### Quick Accuracy Run
```
ck run cmdgen:benchmark.object-detection-large.qaic-loadgen --verbose \
--sut=r282_z93_q5 --sdk=1.6.80 --model=ssd_resnet34 \
--mode=accuracy --scenario=offline
```
#### Full Run
```
ck run cmdgen:benchmark.object-detection-large.qaic-loadgen --verbose \
--sut=r282_z93_q5 --sdk=1.6.80 --model=ssd_resnet34 \
--group.edge --group.closed --offline_target_qps=2175 --singlestream_target_latency=40 --multistream_target_latency=320
```

### AEDK_15W
#### Quick Accuracy Run
```
ck run cmdgen:benchmark.object-detection-large.qaic-loadgen --verbose \
--sut=aedk_15w --sdk=1.6.80 --model=ssd_resnet34 \
--mode=accuracy --scenario=offline 
```
#### Full Run
```
ck run cmdgen:benchmark.object-detection-large.qaic-loadgen --verbose \
--sut=aedk_15w --sdk=1.6.80 --model=ssd_resnet34 \
--group.edge --group.closed --offline_target_qps=120 --singlestream_target_latency=27 --multistream_target_latency=216
```

### AEDK_20W
#### Quick Accuracy Run
```
ck run cmdgen:benchmark.object-detection-large.qaic-loadgen --verbose \
--sut=aedk_20w --sdk=1.6.80 --model=ssd_resnet34 \
--mode=accuracy --scenario=offline
```
#### Full Run
```
ck run cmdgen:benchmark.object-detection-large.qaic-loadgen --verbose \
--sut=aedk_20w --sdk=1.6.80 --model=ssd_resnet34 \
--group.edge --group.closed --offline_target_qps=180 --singlestream_target_latency=28 --multistream_target_latency=224
```

## Datacenter Category
### R282_Z93_Q8
#### Quick Accuracy Run
```
ck run cmdgen:benchmark.object-detection-large.qaic-loadgen --verbose \
--sut=r282_z93_q8 --sdk=1.6.80 --model=ssd_resnet34 \
--mode=accuracy --scenario=offline
```
#### Full Run
```
ck run cmdgen:benchmark.object-detection-large.qaic-loadgen --verbose \
--sut=r282_z93_q8 --sdk=1.6.80 --model=ssd_resnet34 \
--group.datacenter --group.closed --offline_target_qps=3470 --server_target_qps=3380
```

### G292_Z43_Q16
#### Quick Accuracy Run
```
ck run cmdgen:benchmark.object-detection-large.qaic-loadgen --verbose \
--sut=g292_z43_q16 --sdk=1.6.80 --model=ssd_resnet34 \
--mode=accuracy --scenario=offline 
```
#### Full Run
```
ck run cmdgen:benchmark.object-detection-large.qaic-loadgen --verbose \
--sut=g292_z43_q16 --sdk=1.6.80 --model=ssd_resnet34 \
--group.datacenter --group.closed --offline_target_qps=6960 --server_target_qps=6870
```
