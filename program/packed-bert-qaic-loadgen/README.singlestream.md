# Qualcomm Cloud AI - MLPerf Inference - BERT

<a name="submit_bert_99_r282_z93_q1_singlestream"></a>
## Single Stream - BERT 99% Accuracy Single Card

<a name="submit_bert_99_r282_z93_q1_singlestream_accuracy"></a>
### Accuracy

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> time ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q1 --sdk=1.5.9 --model=bert-99 \
--mode=accuracy --scenario=singlestream --override_batch_size=4096 --target_qps=300
...
{"exact_match": 82.40302743614002, "f1": 90.17090568381533}
</pre>

<a name="submit_bert_99_r282_z93_q1_singlestream_performance"></a>
### Performance

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> time ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q1 --sdk=1.5.9 --model=bert-99 \
--mode=performance --scenario=singlestream --override_batch_size=4096 --target_qps=300
</pre>

<a name="submit_bert_99_r282_z93_q1_singlestream_power"></a>
### Power

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> time ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q1 --sdk=1.5.9 --model=bert-99 \
--mode=performance --scenario=singlestream --override_batch_size=4096 --target_qps=300 \
--power=yes --power_singlestream_ip=172.24.66.69 --power_singlestream_port=4951 --sleep_before_ck_benchmark_sec=90
</pre>

<a name="submit_bert_99_r282_z93_q1_singlestream_compliance"></a>
### Compliance

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> time ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q1 --sdk=1.5.9 --model=bert-99 \
--compliance,=TEST05,TEST01 --scenario=singlestream --override_batch_size=4096 --target_qps=300
</pre>


<a name="submit_bert_999_r282_z93_q1_singlestream"></a>
## Single Stream - BERT 99.9% Accuracy Single Card

<a name="submit_bert_999_r282_z93_q1_singlestream_accuracy"></a>
### Accuracy

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> time ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q1 --sdk=1.5.9 --model=bert-99.9 \
--mode=accuracy --scenario=singlestream --override_batch_size=4096 --target_qps=300
...
{"exact_match": 83.59508041627247, "f1": 90.79046230446818}
</pre>

<a name="submit_bert_999_r282_z93_q1_singlestream_performance"></a>
### Performance

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> time ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q1 --sdk=1.5.9 --model=bert-99.9 \
--mode=performance --scenario=singlestream --override_batch_size=4096 --target_qps=300
</pre>

<a name="submit_bert_999_r282_z93_q1_singlestream_power"></a>
### Power

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> time ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q1 --sdk=1.5.9 --model=bert-99.9 \
--mode=performance --scenario=singlestream --override_batch_size=4096 --target_qps=300 \
--power=yes --power_singlestream_ip=172.24.66.69 --power_singlestream_port=4951 --sleep_before_ck_benchmark_sec=90
</pre>

<a name="submit_bert_999_r282_z93_q1_singlestream_compliance"></a>
### Compliance

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> time ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q1 --sdk=1.5.9 --model=bert-99.9 \
--compliance,=TEST05,TEST01 --scenario=singlestream --override_batch_size=4096 --target_qps=300
</pre>

<a name="submit_bert_99_r282_z93_q5_singlestream"></a>
## singlestream - BERT 99% Accuracy Five Card

<a name="submit_bert_99_r282_z93_q5_singlestream_accuracy"></a>
### Accuracy

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> time ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q5 --sdk=1.5.9 --model=bert-99 \
--mode=accuracy --scenario=singlestream --override_batch_size=512 --target_qps=300
...
{"exact_match": 82.40302743614002, "f1": 90.17090568381533}
</pre>

<a name="submit_bert_99_r282_z93_q5_singlestream_performance"></a>
### Performance

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> time ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q5 --sdk=1.5.9 --model=bert-99 \
--mode=performance --scenario=singlestream --override_batch_size=512 --target_qps=300
</pre>

<a name="submit_bert_99_r282_z93_q5_singlestream_power"></a>
### Power

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> time ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q5 --sdk=1.5.9 --model=bert-99 \
--mode=performance --scenario=singlestream --override_batch_size=512 --target_qps=300 \
--power=yes --power_singlestream_ip=172.24.66.69 --power_singlestream_port=4951 --sleep_before_ck_benchmark_sec=90
</pre>

<a name="submit_bert_99_r282_z93_q5_singlestream_compliance"></a>
### Compliance

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> time ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q5 --sdk=1.5.9 --model=bert-99 \
--compliance,=TEST05,TEST01 --scenario=singlestream --override_batch_size=512 --target_qps=300
</pre>


<a name="submit_bert_999_r282_z93_q5_singlestream"></a>
## singlestream - BERT 99.9% Accuracy Five Card

<a name="submit_bert_999_r282_z93_q5_singlestream_accuracy"></a>
### Accuracy

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> time ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q5 --sdk=1.5.9 --model=bert-99.9 \
--mode=accuracy --scenario=singlestream --override_batch_size=512 --target_qps=300
...
{"exact_match": 83.59508041627247, "f1": 90.79046230446818}
</pre>

<a name="submit_bert_999_r282_z93_q5_singlestream_performance"></a>
### Performance

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> time ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q5 --sdk=1.5.9 --model=bert-99.9 \
--mode=performance --scenario=singlestream --override_batch_size=512 --target_qps=300
</pre>

<a name="submit_bert_999_r282_z93_q5_singlestream_power"></a>
### Power

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> time ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q5 --sdk=1.5.9 --model=bert-99.9 \
--mode=performance --scenario=singlestream --override_batch_size=512 --target_qps=300 \
--power=yes --power_singlestream_ip=172.24.66.69 --power_singlestream_port=4951 --sleep_before_ck_benchmark_sec=90
</pre>

<a name="submit_bert_999_r282_z93_q5_singlestream_compliance"></a>
### Compliance

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> time ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=r282_z93_q5 --sdk=1.5.9 --model=bert-99.9 \
--compliance,=TEST05,TEST01 --scenario=singlestream --override_batch_size=512 --target_qps=300
</pre>


## Info

Please contact anton@krai.ai if you have any problems or questions.
