# Qualcomm Cloud AI - MLPerf Inference - Image Classification

**NB:** The `--group.*` commands are only supported with CK &leq; v1.17.0 or &geq; v2.6.0 e.g.:
```
python3 -m pip install ck==2.6.1
```

<a name="aedk_20w"></a>
## AEDK @ 20W TDP

<a name="aedk_20w_all-in-one"></a>
### All-in-one

```
time ck gen cmdgen:benchmark.image-classification.qaic-loadgen --verbose \
--sut=aedk_20w --sdk=1.4.66 --model=resnet50 --group.closed --group.edge \
--dataset_size=50000 --target_qps=9696 --target_latency=1
```

<details>
Specifying <tt>--group.closed --group.edge</tt> runs the benchmark in the following modes and scenarios required for the Closed division under the Edge category:
- Accuracy with the given <tt>--dataset_size</tt> for the Single Stream and Offline scenarios.
- Performance with the given <tt>--target_latency</tt> for the Single Stream scenario and <tt>--target_qps</tt> for the Offline scenario.
- Compliance tests (TEST01, TEST04-A/B, TEST05) with the given <tt>--target_latency</tt> for the Single Stream scenario and <tt>--target_qps</tt> for the Offline scenario.
</details>

<a name="aedk_20w_accuracy"></a>
### Accuracy

```
time ck gen cmdgen:benchmark.image-classification.qaic-loadgen --verbose \
--sut=aedk_20w --sdk=1.4.66 --model=resnet50 --group.edge \
--mode=accuracy --dataset_size=50000 --target_qps=9696 
```

<a name="aedk_20w_performance"></a>
### Performance

```
time ck gen cmdgen:benchmark.image-classification.qaic-loadgen --verbose \
--sut=aedk_20w --sdk=1.4.66 --model=resnet50 --group.edge \
--mode=performance --target_qps=9696 --target_latency=1
```

<a name="aedk_20w_power"></a>
### Power

```
time ck gen cmdgen:benchmark.image-classification.qaic-loadgen --verbose \
--sut=aedk_20w --sdk=1.4.66 --model=resnet50 --group.edge \
--mode=performance --target_qps=9696 --target_latency=1 \
--power=yes --power_server_ip=192.168.0.3 --power_server_port=4949 \
--sleep_before_ck_benchmark_sec=30
```

<a name="aedk_20w_compliance"></a>
### Compliance

```
time ck gen cmdgen:benchmark.image-classification.qaic-loadgen --verbose \
--sut=aedk_20w --sdk=1.4.66 --model=resnet50 --group.edge \
--compliance,=TEST04-A,TEST04-B,TEST05,TEST01 --target_qps=9696 --target_latency=1
```

## Details

[Work-in-progress](https://gist.github.com/psyhtest/82a632f1d1746b852cb891d0416a3120).

## Info

Please contact anton@krai.ai if you have any problems or questions.
