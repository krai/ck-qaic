# Benchmarking

BERT is two-benchmarks-in-one: BERT-99.9 must reach at least 99.9% of the reference accuracy (f1 score of 90.875%), i.e. 90.784%; BERT-99 must reach at least 99.0% of the reference accuracy, i.e. 89.966%. Achieving the latter can be tricky as the best PCV (percentile calibration value) may depend on the host architecture, SDK version, etc.

## Run Options

* `--power` adds power measurement to the experiment run
* `--group.edge` runs two scenarios: `--scenario=offline` and `--scenario=singlestream`
* `--group.datacenter` runs two scenarios: `--scenario=offline` and `--scenario=server`
* `--group.open` runs the following modes: `--mode=accuracy` and `--mode=performance`
* `--group.closed` runs the modes for `--group.open` and in addition the following compliance tests: `--compilance,=TEST01,TEST05`
* `--pre_fan=150 --post_fan=50` - sets [fan speed](https://github.com/krai/ck-qaic/blob/main/docker/README.md#set-the-fan-speed) before and after the benchmark.
* `--vc=12` - sets [device frequency](https://github.com/krai/ck-qaic/blob/main/docker/README.md#device-frequency). If the `vc_value_default` is included in cmdgen metadata it is enough to do `--vc` and the value will be fetched from cmdgen. Without `--vc` the device will operate at max frequency 1450 MHz corresponding to `--vc=17`.
* `--timestamp` - adds timestamp to the filename in the format `%Y%m%dT%H%M%S`.

**We can run individual experiments by using the individual scenario/mode instead of the `group` option**

## Bert-99

### Edge Category
#### R282_Z93_Q1
##### Quick Accuracy Run
```
ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q1 --sdk=1.7.1.12 --model=bert-99 \
--mode=accuracy --scenario=offline
```
##### Full Run
```
ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q1 --sdk=1.7.1.12 --model=bert-99 \
--group.edge --group.closed --offline_target_qps=1 --singlestream_target_latency=1000
```

#### R282_Z93_Q5 
##### Quick Accuracy Run
```
ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q5 --sdk=1.7.1.12 --model=bert-99 \
--mode=accuracy --scenario=offline
```
##### Full Run
```
ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q5 --sdk=1.7.1.12 --model=bert-99 \
--group.edge --group.closed --offline_target_qps=1 --singlestream_target_latency=1000
```

#### AEDK_15W
##### Quick Accuracy Run
```
ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=aedk_15w --sdk=1.7.1.12 --model=bert-99 \
--mode=accuracy --scenario=offline
```
##### Full Run
```
ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=aedk_15w --sdk=1.7.1.12 --model=bert-99 \
--group.edge --group.closed --offline_target_qps=1 --singlestream_target_latency=1000
```

#### AEDK_20W
##### Quick Accuracy Run
```
ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=aedk_20w --sdk=1.7.1.12 --model=bert-99 \
--mode=accuracy --scenario=offline
```
##### Full Run
```
ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=aedk_20w --sdk=1.7.1.12 --model=bert-99 \
--group.edge --group.closed --offline_target_qps=1 --singlestream_target_latency=1000
```

### Datacenter Category
#### R282_Z93_Q8
##### Quick Accuracy Run
```
ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q8 --sdk=1.7.1.12 --model=bert-99 \
--mode=accuracy --scenario=offline
```
##### Full Run
```
ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q8 --sdk=1.7.1.12 --model=bert-99 \
--group.datacenter --group.closed --offline_target_qps=1 --server_target_qps=1
```

#### G292_Z43_Q16
##### Quick Accuracy Run
```
ck run cmdgen:benchmark.packed-bert --verbose \
--sut=g292_z43_q16 --sdk=1.7.1.12 --model=bert-99 \
--mode=accuracy --scenario=offline 
```
##### Full Run
```
ck run cmdgen:benchmark.packed-bert --verbose \
--sut=g292_z43_q16 --sdk=1.7.1.12 --model=bert-99 \
--group.datacenter --group.closed --offline_target_qps=1 --server_target_qps=1
```
## Bert-99.9

### Datacenter Category

#### R282_Z93_Q8

##### Quick Accuracy Run
```
ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q8 --sdk=1.7.1.12 --model=bert-99.9 \
--mode=accuracy --scenario=offline
```
##### Full Run
```
ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q8 --sdk=1.7.1.12 --model=bert-99.9 \
--group.datacenter --group.closed --offline_target_qps=1 --server_target_qps=1
```

#### G292_Z43_Q16
##### Quick Accuracy Run
```
ck run cmdgen:benchmark.packed-bert --verbose \
--sut=g292_z43_q16 --sdk=1.7.1.12 --model=bert-99.9 \
--mode=accuracy --scenario=offline 
```
##### Full Run
```
ck run cmdgen:benchmark.packed-bert --verbose \
--sut=g292_z43_q16 --sdk=1.7.1.12 --model=bert-99.9 \
--group.datacenter --group.closed --offline_target_qps=1 --server_target_qps=1
```

## Docker option

### Launch a reusable Docker container
```
export SDK_VER=1.7.1.12 && CONTAINER_ID=$(ck run cmdgen:benchmark.packed-bert.qaic-loadgen \
--docker=container_only --out=none --sdk=$SDK_VER --model_name=bert --experiment_dir)
```
#### Test
```
docker container ps
```
<details><pre>
CONTAINER ID   IMAGE                              COMMAND               CREATED          STATUS          PORTS     NAMES
c8f890defb1e   krai/mlperf.bert:ubuntu_1.7.1.12   "/bin/bash -c bash"   58 seconds ago   Up 55 seconds             fervent_engelbart
</pre></details>

When `--docker=container_only` or `--docker` are set the following optional parameters can be used:


`--experiment_dir` - directory with experimental data (`${CK_EXPERIMENT_DIR}`by default)

`--volume <experiment_dir_default>:<docker_experiment_dir_default>` - map directory in docker to directory in local machine

`--docker_experiment_dir_default`  - `/home/krai/CK_REPOS/local/experiment` by default

`--experiment_dir_default`  - `${CK_EXPERIMENT_DIR}` by default
 
`--docker_image`   - `krai/mlperf.<model_name>:ubuntu_<sdk>` by default

`<model_name>` - `bert`      

`<sdk>` - for example, `1.7.1.12`

`--shared_group_name` - `qaic` by default

## Measure accuracy

### BERT-99.9
```
export SDK_VER=1.7.1.12 && ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--model=bert-99.9 --scenario=offline --mode=accuracy --dataset_size=10833 \
--sdk=$SDK_VER --container=$CONTAINER_ID --sut=g292_z43_q16
```
<details>
<pre>
{"exact_match": 83.68968779564806, <b>"f1": 90.87603921605954</b>}
Reading examples...
No cached features at '/home/krai/CK_TOOLS/dataset-squad-tokenized-converted-raw-width.384/bert_tokenized_squad_v1_1.pickle'... converting from examples...
Creating tokenizer...
Converting examples to features...
Caching features at '/home/krai/CK_TOOLS/dataset-squad-tokenized-converted-raw-width.384/bert_tokenized_squad_v1_1.pickle'...
Loading LoadGen logs...
Post-processing predictions...
Writing predictions to: predictions.json
Evaluating predictions...
real    2m22.933s
user    0m0.191s
sys     0m0.124s
</pre>
<b>NB:</b> Most of the time is spent on calculating the accuracy metric rather than on processing 10,833 samples.
</details>

#### Check
```
ck list $CK_EXPERIMENT_REPO:experiment:*
```
<details><pre>
mlperf_v2.1-closed-g292_z43_q16-qaic-v1.7.1.12-aic100-<b>bert-99.9-offline-accuracy-dataset_size.10833</b>
<pre></details>

### BERT-99

```
export SDK_VER=1.7.1.12 && ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--model=bert-99 --mode=accuracy --scenario=offline --dataset_size=10833 \
--sdk=$SDK_VER --container=$CONTAINER_ID --sut=g292_z43_q16
```
<details>
- With the default PCV (98.85% of the reference):
<pre>{"exact_match": 82.10028382213812, <b>"f1": 89.83088437186652</b>}</pre>
- With the 99.85% PCV (99.10% of the reference): 
<pre>{"exact_match": 82.2421948912015, <b>"f1": 90.05632728113551}</b></pre>
- With the best PCV (99.30% of the reference):
<pre>{"exact_match": 82.83822138126774, <b>"f1": 90.24240186119648</b>}</pre>
</details>

## Measure performance

### Offline

When measuring the performance under the Offline scenario, the target QPS (queries per second) parameter should be specified as close to the actual system performance as possible to achieve the required minimum duration of 10 minutes.

```
export SDK_VER=1.7.1.12 && ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--model=bert-99 --mode=performance --scenario=offline \
--sdk=$SDK_VER --container=$CONTAINER_ID --sut=g292_z43_q16 --target_qps=11111
```
<details>
<pre>
================================================
MLPerf Results Summary
================================================
SUT name : QAIC_SUT
Scenario : Offline
Mode     : PerformanceOnly
<b>Samples per second: 11022.4</b>
<b>Result is : VALID</b>
  Min duration satisfied : Yes
  Min queries satisfied : Yes
</pre><pre>
================================================
Additional Stats
================================================
Min latency (ns)                : 13827778
Max latency (ns)                : 659318890980
Mean latency (ns)               : 329709531619
50.00 percentile latency (ns)   : 329746545192
90.00 percentile latency (ns)   : 593408489314
95.00 percentile latency (ns)   : 626361044806
97.00 percentile latency (ns)   : 639545767581
99.00 percentile latency (ns)   : 652727350675
99.90 percentile latency (ns)   : 658661794712
</pre><pre>
================================================
Test Parameters Used
================================================
samples_per_query : 7267260
target_qps : 11011
target_latency (ns): 0
max_async_queries : 1
min_duration (ms): 600000
max_duration (ms): 0
min_query_count : 1
max_query_count : 0
qsl_rng_seed : 1624344308455410291
sample_index_rng_seed : 517984244576520566
schedule_rng_seed : 10051496985653635065
accuracy_log_rng_seed : 0
accuracy_log_probability : 0
accuracy_log_sampling_target : 0
print_timestamps : 0
performance_issue_unique : 0
performance_issue_same : 0
performance_issue_same_index : 0
performance_sample_count : 10833
</pre><pre>
No warnings encountered during test.
</pre>
</details>

Setting the target QPS parameter to about 1/10th of the actual system performance reduces the execution time to about 1 minute, which is handy for quick test runs.

```
export SDK_VER=1.7.1.12 && ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--model=bert-99 --mode=performance --scenario=offline \
--sdk=$SDK_VER --container=$CONTAINER_ID --sut=g292_z43_q16 --target_qps=1111
```
<details>
<pre>
================================================
MLPerf Results Summary
================================================
SUT name : QAIC_SUT
Scenario : Offline
Mode     : PerformanceOnly
Samples per second: 11023.4
<b>Result is : INVALID</b>
<b>  Min duration satisfied : NO</b>
  Min queries satisfied : Yes
Recommendations:
<b> * Increase expected QPS so the loadgen pre-generates a larger (coalesced) query.</b>
</pre><pre>
================================================
Additional Stats
================================================
Min latency (ns)                : 13319750
Max latency (ns)                : 66518421631
Mean latency (ns)               : 33266286613
50.00 percentile latency (ns)   : 33264512160
90.00 percentile latency (ns)   : 59862782613
95.00 percentile latency (ns)   : 63192916020
97.00 percentile latency (ns)   : 64522849990
99.00 percentile latency (ns)   : 65849641866
99.90 percentile latency (ns)   : 66448261447
</pre><pre>
================================================
Test Parameters Used
================================================
samples_per_query : 733260
target_qps : 1111
target_latency (ns): 0
max_async_queries : 1
min_duration (ms): 600000
max_duration (ms): 0
min_query_count : 1
max_query_count : 0
qsl_rng_seed : 1624344308455410291
sample_index_rng_seed : 517984244576520566
schedule_rng_seed : 10051496985653635065
accuracy_log_rng_seed : 0
accuracy_log_probability : 0
accuracy_log_sampling_target : 0
print_timestamps : 0
performance_issue_unique : 0
performance_issue_same : 0
performance_issue_same_index : 0
performance_sample_count : 10833
</pre><pre>
No warnings encountered during test.
</pre>
</details>

### Server

When measuring the performance under the Server scenario, the target QPS is expected to be within 95% of that for the Offline scenario e.g.:
```
export SDK_VER=1.7.1.12 && ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--model=bert-99 --mode=performance --scenario=server \
--sdk=$SDK_VER --container=$CONTAINER_ID --sut=g292_z43_q16 --target_qps=10555
```

Unfortunately, for the Server scenario, reducing the target QPS also leads to decreasing the system load, so you cannot do that to reduce the number of queries for a test run. For that, use the `--query_count` parameter e.g.:
```
export SDK_VER=1.7.1.12 && ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--model=bert-99 --mode=performance --scenario=server \
--sdk=$SDK_VER --container=$CONTAINER_ID --sut=g292_z43_q16 --target_qps=10555 --query_count=40320
```
<details>
<pre>
================================================
MLPerf Results Summary
================================================
SUT name : QAIC_SUT
Scenario : Server
Mode     : PerformanceOnly
Scheduled samples per second : 10506.00
<b>Result is : INVALID</b>
  Performance constraints satisfied : Yes
<b>  Min duration satisfied : NO</b>
  Min queries satisfied : Yes
Recommendations:
<b> * Increase the target QPS so the loadgen pre-generates more queries.</b>
</pre><pre>
================================================
Additional Stats
================================================
Completed samples per second    : 10433.21
Min latency (ns)                : 8840838
Max latency (ns)                : 127487128
Mean latency (ns)               : 60321693
50.00 percentile latency (ns)   : 60803804
90.00 percentile latency (ns)   : 88844592
95.00 percentile latency (ns)   : 95615046
97.00 percentile latency (ns)   : 98577624
99.00 percentile latency (ns)   : 104054414
99.90 percentile latency (ns)   : 113836408
</pre><pre>
================================================
Test Parameters Used
================================================
samples_per_query : 1
target_qps : 10555
target_latency (ns): 130000000
max_async_queries : 0
min_duration (ms): 600000
max_duration (ms): 0
min_query_count : 40320
max_query_count : 40320
qsl_rng_seed : 1624344308455410291
sample_index_rng_seed : 517984244576520566
schedule_rng_seed : 10051496985653635065
accuracy_log_rng_seed : 0
accuracy_log_probability : 0
accuracy_log_sampling_target : 0
print_timestamps : 0
performance_issue_unique : 0
performance_issue_same : 0
performance_issue_same_index : 0
performance_sample_count : 10833
</pre><pre>
No warnings encountered during test.
2 ERRORS encountered. See detailed log.
</pre>
</details>

## Make a full submission run

```
export SDK_VER=1.7.1.12 && ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--model=bert-99 --sut=g292_z43_q16 --group.datacenter --group.closed \
--target_qps=11111 --server_target_qps=10777 --max_wait=10000 --override_batch_size=4096 \
--sdk=$SDK_VER --container=$CONTAINER_ID
```

## Miscellaneous useful commands

### Useful `ipmitool` commands

#### Read the fan speed

##### Gigabyte R282-Z93
```
sudo ipmitool sensor get BPB_FAN_1A
```
<details><pre>
Locating sensor record...
Sensor ID              : BPB_FAN_1A (0xa0)
 Entity ID             : 29.1
 Sensor Type (Threshold)  : Fan
<b> Sensor Reading        : 8100 (+/- 0) RPM</b>
 Status                : ok
 Lower Non-Recoverable : na
 Lower Critical        : 1200.000
 Lower Non-Critical    : 1500.000
 Upper Non-Critical    : na
 Upper Critical        : na
 Upper Non-Recoverable : na
 Positive Hysteresis   : Unspecified
 Negative Hysteresis   : 150.000
 Assertion Events      :
 Assertions Enabled    : lnc- lcr-
 Deassertions Enabled  : lnc- lcr-
</pre></details>

##### Gigabyte G292-Z43
```
sudo ipmitool sensor get SYS_FAN2
```
<details><pre>
Locating sensor record...
Sensor ID              : SYS_FAN2 (0xa3)
 Entity ID             : 29.4
 Sensor Type (Threshold)  : Fan
 <b>Sensor Reading        : 10800 (+/- 0) RPM</b>
 Status                : ok
 Lower Non-Recoverable : 0.000
 Lower Critical        : 1200.000
 Lower Non-Critical    : 1500.000
 Upper Non-Critical    : 38250.000
 Upper Critical        : 38250.000
 Upper Non-Recoverable : 38250.000
 Positive Hysteresis   : Unspecified
 Negative Hysteresis   : 150.000
 Assertion Events      :
 Assertions Enabled    : lnc- lnc+ lcr- lcr+ lnr- lnr+ unc- unc+ ucr- ucr+ unr- unr+
 Deassertions Enabled  : lnc- lnc+ lcr- lcr+ lnr- lnr+ unc- unc+ ucr- ucr+ unr- unr+
</pre></details>

#### Set the fan speed

##### Gigabyte R282-Z93, G292-Z43

Value | Speed, RPM
-|-
0     | 3,000
25    | 4,200
50    | 5,550
75    | 6,750
100   | 8,100
125   | 9,450
150   | 10,800
200   | 13,350
250   | 15,900

For example, to set the fan speed to 8,100 RPM, use <b>100</b>:

<pre>
sudo ipmitool raw 0x2e 0x10 0x0a 0x3c 0 64 1 <b>100</b> 0xFF
</pre>

### Useful `watch` commands

#### Device frequency
```
watch -n 1 "/opt/qti-aic/tools/qaic-util -q | grep NSP\ Fr | cut -c 15-"
```

#### Device power
```
watch -n 1 "sensors | grep qaic-pci -A7 | grep power1 | cut -c 10-"
```

#### Device temperature
```
watch -n 1 "sensors | grep qaic-pci -A7 | grep temp2 | cut -c 10-"
````

#### Active users
```
watch -n 10 "who -a | grep -v old | grep -v exit=0 | grep -v LOGIN | grep -v system | grep -v run-level"
```

#### Docker images
```
watch -n 60 "docker image ls | head -n 5"
```

