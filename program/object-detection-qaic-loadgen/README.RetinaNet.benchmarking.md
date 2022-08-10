# Benchmarking

## Edge Category
### R282_Z93_Q2

#### Quick Accuracy Run
```
ck run cmdgen:benchmark.object-detection.qaic-loadgen --verbose \
--sut=r282_z93_q2_prev --sdk=1.8.0.73 --model=retinanet \
--mode=accuracy --scenario=offline
```
#### Full Run
```
ck run cmdgen:benchmark.object-detection.qaic-loadgen --verbose \
--sut=r282_z93_q2_prev --sdk=1.8.0.73 --model=retinanet \
--group.edge --group.closed --offline_target_qps=375 --singlestream_target_latency=30 --multistream_target_latency=65
```

### R282_Z93_Q5
#### Quick Accuracy Run
```
ck run cmdgen:benchmark.object-detection.qaic-loadgen --verbose \
--sut=r282_z93_q5_prev --sdk=1.8.0.73 --model=retinanet \
--mode=accuracy --scenario=offline
```
#### Full Run
```
ck run cmdgen:benchmark.object-detection.qaic-loadgen --verbose \
--sut=r282_z93_q5_prev --sdk=1.8.0.73 --model=retinanet \
--group.edge --group.closed --offline_target_qps=930 --singlestream_target_latency=30 --multistream_target_latency=60
```

### AEDK
#### Quick Accuracy Run
```
ck run cmdgen:benchmark.object-detection.qaic-loadgen --verbose \
--sut=gloria_prev --sdk=1.8.0.73 --model=retinanet \
--mode=accuracy --scenario=offline
```
#### Full Run
```
ck run cmdgen:benchmark.object-detection.qaic-loadgen --verbose \
--sut=gloria_prev --sdk=1.8.0.73 --model=retinanet \
--group.edge --group.closed --offline_target_qps=70 --singlestream_target_latency=40 --multistream_target_latency=320
```


## Datacenter Category
### R282_Z93_Q8
#### Quick Accuracy Run
```
ck run cmdgen:benchmark.object-detection.qaic-loadgen --verbose \
--sut=r282_z93_q8_prev --sdk=1.8.0.73 --model=retinanet \
--mode=accuracy --scenario=offline
```
#### Full Run
```
ck run cmdgen:benchmark.object-detection.qaic-loadgen --verbose \
--sut=r282_z93_q8_prev --sdk=1.8.0.73 --model=retinanet \
--group.datacenter --group.closed --offline_target_qps=1440 --server_target_qps=1000
```

### G292_Z43_Q18
#### Quick Accuracy Run
```
ck run cmdgen:benchmark.object-detection.qaic-loadgen --verbose \
--sut=g292_z43_q18_prev --sdk=1.8.0.73 --model=retinanet \
--mode=accuracy --scenario=offline
```
#### Full Run
```
ck run cmdgen:benchmark.object-detection.qaic-loadgen --verbose \
--sut=g292_z43_q18_prev --sdk=1.8.0.73 --model=retinanet \
--group.datacenter --group.closed --offline_target_qps=3200 --server_target_qps=2000
```
