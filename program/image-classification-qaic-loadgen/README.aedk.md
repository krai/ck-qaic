:toc:
:toclevels: 2

# Qualcomm Cloud AI - MLPerf Inference - Image Classification

**NB:** The `--group.*` commands are only supported with CK &geq; v2.6.0 e.g.:
```
python3 -m pip install ck==2.6.1
```

<a name="aedk_20w"></a>
## AEDK @ 20W TDP

<a name="aedk_20w_all-in-one"></a>
### All-in-one (6 experiments per scenario)
```
time ck gen cmdgen:benchmark.image-classification.qaic-loadgen --verbose \
--sut=aedk_20w --sdk=1.4.66 --model=resnet50 --group.edge --group.closed \
--dataset_size=50000 --target_qps=9696 --target_latency=1
```
<details>
Specifying <tt>--group.edge --group.closed</tt> runs the benchmark in the following modes required for the Closed division and scenarios required under the Edge category:
<ul>
<li>Accuracy with the given <tt>--dataset_size</tt> for the Offline and Single Stream scenarios.</li>
<li>Performance with the given <tt>--target_qps</tt> for the Offline scenario and <tt>--target_latency</tt> for the Single Stream scenario.</li>
<li>Compliance tests (TEST01, TEST04-A/B, TEST05) with the given <tt>--target_qps</tt> for the Offline scenario and <tt>--target_latency</tt> for the Single Stream scenario.</li>
</ul>
</details>

<a name="aedk_20w_all-in-one_power"></a>
#### With Power (7 CK entries per scenario)
To measure power consumption as per the [MLPerf Power rules](https://github.com/krai/inference_policies/blob/krai-power-v2.0/power_measurement.adoc), specify additional flags e.g.:
```
time ck gen cmdgen:benchmark.image-classification.qaic-loadgen --verbose \
--sut=aedk_20w --sdk=1.4.66 --model=resnet50 --group.edge --group.closed \
--dataset_size=50000 --target_qps=9696 --target_latency=1 \
--power=yes --power_server_ip=192.168.0.3 --power_server_port=4949 --sleep_before_ck_benchmark_sec=30
```

<a name="aedk_20w_accuracy"></a>
### Accuracy (1 experiment per scenario)
```
time ck gen cmdgen:benchmark.image-classification.qaic-loadgen --verbose \
--sut=aedk_20w --sdk=1.4.66 --model=resnet50 --group.edge --mode=accuracy \
--dataset_size=50000 --target_qps=9696 
```
<details>
Specifying <tt>--group.edge --mode=accuracy</tt> runs the benchmark in the Accuracy mode with the given <tt>--dataset_size</tt> for the Offline and Single Stream scenarios required under the Edge category.
</details>

<a name="aedk_20w_performance"></a>
### Performance (1 experiment per scenario)
```
time ck gen cmdgen:benchmark.image-classification.qaic-loadgen --verbose \
--sut=aedk_20w --sdk=1.4.66 --model=resnet50 --group.edge --mode=performance \
--target_qps=9696 --target_latency=1
```
<details>
Specifying <tt>--group.edge --mode=performance</tt> runs the benchmark in the Performance mode with the given <tt>--target_qps</tt> for the Offline scenario and <tt>--target_latency</tt> for the Single Stream scenario required under the Edge category.
</details>

<a name="aedk_20w_performance_power"></a>
#### With Power (2 CK entries per scenario)
To measure power consumption as per the [MLPerf Power rules](https://github.com/krai/inference_policies/blob/krai-power-v2.0/power_measurement.adoc), specify additional flags e.g.:
```
time ck gen cmdgen:benchmark.image-classification.qaic-loadgen --verbose \
--sut=aedk_20w --sdk=1.4.66 --model=resnet50 --group.edge --mode=performance \
--target_qps=9696 --target_latency=1 --sleep_before_ck_benchmark_sec=30 \
--power=yes --power_server_ip=192.168.0.3 --power_server_port=4949
```

<a name="aedk_20w_compliance"></a>
### Compliance (4 experiments per scenario)
```
time ck gen cmdgen:benchmark.image-classification.qaic-loadgen --verbose \
--sut=aedk_20w --sdk=1.4.66 --model=resnet50 --group.edge --compliance,=TEST04-A,TEST04-B,TEST05,TEST01 \
--target_qps=9696 --target_latency=1
```
<details>
Specifying <tt>--group.edge --compliance,=</tt> runs the given Compliance tests required for the Closed division with the given <tt>--target_qps</tt> for the Offline scenario and <tt>--target_latency</tt> for the Single Stream scenario required under the Edge category.
</details>
 
## Details
[Work-in-progress](https://gist.github.com/psyhtest/82a632f1d1746b852cb891d0416a3120).

## Info
Please contact anton@krai.ai if you have any problems or questions.