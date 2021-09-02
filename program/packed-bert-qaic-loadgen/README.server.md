# Qualcomm Cloud AI - MLPerf Inference - BERT

<a name="submit_bert_99_r282_z93_q8_server"></a>
## Server - BERT 99% Accuracy Eight Card

<a name="submit_bert_99_r282_z93_q8_server_accuracy"></a>
### Accuracy

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> time ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q8 --sdk=1.5.9 --model=bert-99 \
--mode=accuracy --scenario=server --override_batch_size=512 --target_qps=300
...
{"exact_match": 82.40302743614002, "f1": 90.17090568381533}
</pre>

<a name="submit_bert_99_r282_z93_q8_server_performance"></a>
### Performance

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> time ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q8 --sdk=1.5.9 --model=bert-99 \
--mode=performance --scenario=server --override_batch_size=512 --target_qps=300
</pre>

<a name="submit_bert_99_r282_z93_q8_server_power"></a>
### Power

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> time ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q8 --sdk=1.5.9 --model=bert-99 \
--mode=performance --scenario=server --override_batch_size=512 --target_qps=300 \
--power=yes --power_server_ip=172.24.66.69 --power_server_port=4951 --sleep_before_ck_benchmark_sec=90
</pre>

<a name="submit_bert_99_r282_z93_q8_server_compliance"></a>
### Compliance

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> time ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q8 --sdk=1.5.9 --model=bert-99 \
--compliance,=TEST05,TEST01 --scenario=server --override_batch_size=512 --target_qps=300
</pre>


<a name="submit_bert_999_r282_z93_q8_server"></a>
## Server - BERT 99.9% Accuracy Eight Card

<a name="submit_bert_999_r282_z93_q8_server_accuracy"></a>
### Accuracy

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> time ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q8 --sdk=1.5.9 --model=bert-99.9 \
--mode=accuracy --scenario=server --override_batch_size=512 --target_qps=300
...
{"exact_match": 83.59508041627247, "f1": 90.79046230446818}
</pre>

<a name="submit_bert_999_r282_z93_q8_server_performance"></a>
### Performance

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> time ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q8 --sdk=1.5.9 --model=bert-99.9 \
--mode=performance --scenario=server --override_batch_size=512 --target_qps=300
</pre>

<a name="submit_bert_999_r282_z93_q8_server_power"></a>
### Power

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> time ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q8 --sdk=1.5.9 --model=bert-99.9 \
--mode=performance --scenario=server --override_batch_size=512 --target_qps=300 \
--power=yes --power_server_ip=172.24.66.69 --power_server_port=4951 --sleep_before_ck_benchmark_sec=90
</pre>

<a name="submit_bert_999_r282_z93_q8_server_compliance"></a>
### Compliance

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> time ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q8 --sdk=1.5.9 --model=bert-99.9 \
--compliance,=TEST05,TEST01 --scenario=server --override_batch_size=512 --target_qps=300
</pre>


<a name="submit_bert_99_r292_z93_q16_server"></a>
## Server - BERT 99% Accuracy Sixteen Card

<a name="submit_bert_99_r292_z93_q16_server_accuracy"></a>
### Accuracy

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> time ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r292_z93_q16 --sdk=1.5.9 --model=bert-99 \
--mode=accuracy --scenario=server --override_batch_size=512 --target_qps=300
...
{"exact_match": 82.40302743614002, "f1": 90.17090568381533}
</pre>

<a name="submit_bert_99_r292_z93_q16_server_performance"></a>
### Performance

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> time ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r292_z93_q16 --sdk=1.5.9 --model=bert-99 \
--mode=performance --scenario=server --override_batch_size=512 --target_qps=300
</pre>

<a name="submit_bert_99_r292_z93_q16_server_power"></a>
### Power

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> time ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r292_z93_q16 --sdk=1.5.9 --model=bert-99 \
--mode=performance --scenario=server --override_batch_size=512 --target_qps=300 \
--power=yes --power_server_ip=172.24.66.69 --power_server_port=4951 --sleep_before_ck_benchmark_sec=90
</pre>

<a name="submit_bert_99_r292_z93_q16_server_compliance"></a>
### Compliance

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> time ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r292_z93_q16 --sdk=1.5.9 --model=bert-99 \
--compliance,=TEST05,TEST01 --scenario=server --override_batch_size=512 --target_qps=300
</pre>


<a name="submit_bert_999_r292_z93_q16_server"></a>
## Server - BERT 99.9% Accuracy Sixteen Card

<a name="submit_bert_999_r292_z93_q16_server_accuracy"></a>
### Accuracy

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> time ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r292_z93_q16 --sdk=1.5.9 --model=bert-99.9 \
--mode=accuracy --scenario=server --override_batch_size=512 --target_qps=300
...
{"exact_match": 83.59508041627247, "f1": 90.79046230446818}
</pre>

<a name="submit_bert_999_r292_z93_q16_server_performance"></a>
### Performance

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> time ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r292_z93_q16 --sdk=1.5.9 --model=bert-99.9 \
--mode=performance --scenario=server --override_batch_size=512 --target_qps=300
</pre>

<a name="submit_bert_999_r292_z93_q16_server_power"></a>
### Power

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> time ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q1 --sdk=1.5.9 --model=bert-99.9 \
--mode=performance --scenario=server --override_batch_size=512 --target_qps=300 \
--power=yes --power_server_ip=172.24.66.69 --power_server_port=4951 --sleep_before_ck_benchmark_sec=90
</pre>

<a name="submit_bert_999_r292_z93_q16_server_compliance"></a>
### Compliance

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> time ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r292_z93_q16 --sdk=1.5.9 --model=bert-99.9 \
--compliance,=TEST05,TEST01 --scenario=server --override_batch_size=512 --target_qps=300
</pre>


## Info

Please contact anton@krai.ai if you have any problems or questions.
