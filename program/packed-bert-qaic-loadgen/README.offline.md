# Qualcomm Cloud AI - MLPerf Inference - BERT

<a name="submit_bert_99_r282_z93_q1_offline"></a>
## Offline - BERT 99% Accuracy Single Card

<a name="submit_bert_99_r282_z93_q1_offline_accuracy"></a>
### Accuracy

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> time ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q1 --sdk=1.5.9 --model=bert-99 \
--mode=accuracy --scenario=offline --override_batch_size=4096 --target_qps=300
...
{"exact_match": 82.40302743614002, "f1": 90.17090568381533}
</pre>

<a name="submit_bert_99_r282_z93_q1_offline_performance"></a>
### Performance

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> time ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q1 --sdk=1.5.9 --model=bert-99 \
--mode=performance --scenario=offline --override_batch_size=4096 --target_qps=300
</pre>

<a name="submit_bert_99_r282_z93_q1_offline_power"></a>
### Power

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> time ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q1 --sdk=1.5.9 --model=bert-99 \
--mode=performance --scenario=offline --override_batch_size=4096 --target_qps=300 \
--power=yes --power_server_ip=172.24.66.69 --power_server_port=4951 --sleep_before_ck_benchmark_sec=90
</pre>

<a name="submit_bert_99_r282_z93_q1_offline_compliance"></a>
### Compliance

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> time ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q1 --sdk=1.5.9 --model=bert-99 \
--compliance,=TEST05,TEST01 --scenario=offline --override_batch_size=4096 --target_qps=300
</pre>


<a name="submit_bert_999_r282_z93_q1_offline"></a>
## Offline - BERT 99.9% Accuracy Single Card

<a name="submit_bert_999_r282_z93_q1_offline_accuracy"></a>
### Accuracy

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> time ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q1 --sdk=1.5.9 --model=bert-99.9 \
--mode=accuracy --scenario=offline --override_batch_size=4096 --target_qps=300
...
{"exact_match": 83.59508041627247, "f1": 90.79046230446818}
</pre>

<a name="submit_bert_999_r282_z93_q1_offline_performance"></a>
### Performance

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> time ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q1 --sdk=1.5.9 --model=bert-99.9 \
--mode=performance --scenario=offline --override_batch_size=4096 --target_qps=300
</pre>

<a name="submit_bert_999_r282_z93_q1_offline_power"></a>
### Power

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> time ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q1 --sdk=1.5.9 --model=bert-99.9 \
--mode=performance --scenario=offline --override_batch_size=4096 --target_qps=300 \
--power=yes --power_server_ip=172.24.66.69 --power_server_port=4951 --sleep_before_ck_benchmark_sec=90
</pre>

<a name="submit_bert_999_r282_z93_q1_offline_compliance"></a>
### Compliance

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> time ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q1 --sdk=1.5.9 --model=bert-99.9 \
--compliance,=TEST05,TEST01 --scenario=offline --override_batch_size=4096 --target_qps=300
</pre>


<a name="submit_bert_99_r282_z93_q5_offline"></a>
## Offline - BERT 99% Accuracy Five Card

<a name="submit_bert_99_r282_z93_q5_offline_accuracy"></a>
### Accuracy

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> time ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q5 --sdk=1.5.9 --model=bert-99 \
--mode=accuracy --scenario=offline --override_batch_size=4096 --target_qps=300
...
{"exact_match": 82.40302743614002, "f1": 90.17090568381533}
</pre>

<a name="submit_bert_99_r282_z93_q5_offline_performance"></a>
### Performance

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> time ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q5 --sdk=1.5.9 --model=bert-99 \
--mode=performance --scenario=offline --override_batch_size=4096 --target_qps=300
</pre>

<a name="submit_bert_99_r282_z93_q5_offline_power"></a>
### Power

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> time ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q5 --sdk=1.5.9 --model=bert-99 \
--mode=performance --scenario=offline --override_batch_size=4096 --target_qps=300 \
--power=yes --power_server_ip=172.24.66.69 --power_server_port=4951 --sleep_before_ck_benchmark_sec=90
</pre>

<a name="submit_bert_99_r282_z93_q5_offline_compliance"></a>
### Compliance

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> time ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q5 --sdk=1.5.9 --model=bert-99 \
--compliance,=TEST05,TEST01 --scenario=offline --override_batch_size=4096 --target_qps=300
</pre>


<a name="submit_bert_999_r282_z93_q5_offline"></a>
## Offline - BERT 99.9% Accuracy Five Card

<a name="submit_bert_999_r282_z93_q5_offline_accuracy"></a>
### Accuracy

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> time ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q5 --sdk=1.5.9 --model=bert-99.9 \
--mode=accuracy --scenario=offline --override_batch_size=4096 --target_qps=300
...
{"exact_match": 83.59508041627247, "f1": 90.79046230446818}
</pre>

<a name="submit_bert_999_r282_z93_q5_offline_performance"></a>
### Performance

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> time ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q5 --sdk=1.5.9 --model=bert-99.9 \
--mode=performance --scenario=offline --override_batch_size=4096 --target_qps=300
</pre>

<a name="submit_bert_999_r282_z93_q5_offline_power"></a>
### Power

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> time ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q5 --sdk=1.5.9 --model=bert-99.9 \
--mode=performance --scenario=offline --override_batch_size=4096 --target_qps=300 \
--power=yes --power_server_ip=172.24.66.69 --power_server_port=4951 --sleep_before_ck_benchmark_sec=90
</pre>

<a name="submit_bert_999_r282_z93_q5_offline_compliance"></a>
### Compliance

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> time ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q5 --sdk=1.5.9 --model=bert-99.9 \
--compliance,=TEST05,TEST01 --scenario=offline --override_batch_size=4096 --target_qps=300
</pre>


<a name="submit_bert_99_r282_z93_q8_offline"></a>
## Offline - BERT 99% Accuracy Eight Card

<a name="submit_bert_99_r282_z93_q8_offline_accuracy"></a>
### Accuracy

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> time ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q8 --sdk=1.5.9 --model=bert-99 \
--mode=accuracy --scenario=offline --override_batch_size=4096 --target_qps=300
...
{"exact_match": 82.40302743614002, "f1": 90.17090568381533}
</pre>

<a name="submit_bert_99_r282_z93_q8_offline_performance"></a>
### Performance

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> time ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q8 --sdk=1.5.9 --model=bert-99 \
--mode=performance --scenario=offline --override_batch_size=4096 --target_qps=300
</pre>

<a name="submit_bert_99_r282_z93_q8_offline_power"></a>
### Power

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> time ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q8 --sdk=1.5.9 --model=bert-99 \
--mode=performance --scenario=offline --override_batch_size=4096 --target_qps=300 \
--power=yes --power_server_ip=172.24.66.69 --power_server_port=4951 --sleep_before_ck_benchmark_sec=90
</pre>

<a name="submit_bert_99_r282_z93_q8_offline_compliance"></a>
### Compliance

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> time ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q8 --sdk=1.5.9 --model=bert-99 \
--compliance,=TEST05,TEST01 --scenario=offline --override_batch_size=4096 --target_qps=300
</pre>


<a name="submit_bert_999_r282_z93_q8_offline"></a>
## Offline - BERT 99/9% Accuracy Eight Card

<a name="submit_bert_999_r282_z93_q8_offline_accuracy"></a>
### Accuracy

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> time ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q8 --sdk=1.5.9 --model=bert-99.9 \
--mode=accuracy --scenario=offline --override_batch_size=4096 --target_qps=300
...
{"exact_match": 83.59508041627247, "f1": 90.79046230446818}
</pre>

<a name="submit_bert_999_r282_z93_q8_offline_performance"></a>
### Performance

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> time ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q8 --sdk=1.5.9 --model=bert-99.9 \
--mode=performance --scenario=offline --override_batch_size=4096 --target_qps=300
</pre>

<a name="submit_bert_999_r282_z93_q8_offline_power"></a>
### Power

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> time ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q8 --sdk=1.5.9 --model=bert-99.9 \
--mode=performance --scenario=offline --override_batch_size=4096 --target_qps=300 \
--power=yes --power_server_ip=172.24.66.69 --power_server_port=4951 --sleep_before_ck_benchmark_sec=90
</pre>

<a name="submit_bert_999_r282_z93_q8_offline_compliance"></a>
### Compliance

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> time ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q8 --sdk=1.5.9 --model=bert-99.9 \
--compliance,=TEST05,TEST01 --scenario=offline --override_batch_size=4096 --target_qps=300
</pre>


<a name="submit_bert_99_r292_z93_q16_offline"></a>
## Offline - BERT 99% Accuracy Sixteen Card

<a name="submit_bert_99_r292_z93_q16_offline_accuracy"></a>
### Accuracy

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> time ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r292_z93_q16 --sdk=1.5.9 --model=bert-99 \
--mode=accuracy --scenario=offline --override_batch_size=4096 --target_qps=300
...
{"exact_match": 82.40302743614002, "f1": 90.17090568381533}
</pre>

<a name="submit_bert_99_r292_z93_q16_offline_performance"></a>
### Performance

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> time ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r292_z93_q16 --sdk=1.5.9 --model=bert-99 \
--mode=performance --scenario=offline --override_batch_size=4096 --target_qps=300
</pre>

<a name="submit_bert_99_r292_z93_q16_offline_power"></a>
### Power

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> time ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r292_z93_q16 --sdk=1.5.9 --model=bert-99 \
--mode=performance --scenario=offline --override_batch_size=4096 --target_qps=300 \
--power=yes --power_server_ip=172.24.66.69 --power_server_port=4951 --sleep_before_ck_benchmark_sec=90
</pre>

<a name="submit_bert_99_r292_z93_q16_offline_compliance"></a>
### Compliance

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> time ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r292_z93_q16 --sdk=1.5.9 --model=bert-99 \
--compliance,=TEST05,TEST01 --scenario=offline --override_batch_size=4096 --target_qps=300
</pre>


<a name="submit_bert_999_r292_z93_q16_offline"></a>
## Offline - BERT 99.9% Accuracy Sixteen Card

<a name="submit_bert_999_r292_z93_q16_offline_accuracy"></a>
### Accuracy

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> time ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r292_z93_q16 --sdk=1.5.9 --model=bert-99.9 \
--mode=accuracy --scenario=offline --override_batch_size=4096 --target_qps=300
...
{"exact_match": 83.59508041627247, "f1": 90.79046230446818}
</pre>

<a name="submit_bert_999_r292_z93_q16_offline_performance"></a>
### Performance

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> time ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r292_z93_q16 --sdk=1.5.9 --model=bert-99.9 \
--mode=performance --scenario=offline --override_batch_size=4096 --target_qps=300
</pre>

<a name="submit_bert_999_r292_z93_q16_offline_power"></a>
### Power

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> time ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q1 --sdk=1.5.9 --model=bert-99.9 \
--mode=performance --scenario=offline --override_batch_size=4096 --target_qps=300 \
--power=yes --power_server_ip=172.24.66.69 --power_server_port=4951 --sleep_before_ck_benchmark_sec=90
</pre>

<a name="submit_bert_999_r292_z93_q16_offline_compliance"></a>
### Compliance

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> time ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r292_z93_q16 --sdk=1.5.9 --model=bert-99.9 \
--compliance,=TEST05,TEST01 --scenario=offline --override_batch_size=4096 --target_qps=300
</pre>


## Info

Please contact anton@krai.ai if you have any problems or questions.
