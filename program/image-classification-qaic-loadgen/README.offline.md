# Qualcomm Cloud AI - MLPerf Inference - Image Classification

<a name="submit_aedk_20w_offline"></a>
## Offline

<a name="submit_aedk_20w_offline_accuracy"></a>
### Accuracy

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> time ck run cmdgen:benchmark.image-classification.qaic-loadgen --verbose \
--sut=aedk_20w --sdk=1.5.00 --model=resnet50 --scenario=offline \
--mode=accuracy --dataset_size=50000 --buffer_size=5000

--------------------------------
accuracy=75.928%, good=37964, total=50000

--------------------------------
</pre>

<a name="submit_aedk_20w_offline_performance"></a>
### Performance

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> time ck run cmdgen:benchmark.image-classification.qaic-loadgen --verbose \
--sut=aedk_20w --sdk=1.5.00 --model=resnet50 --scenario=offline \
--mode=performance --target_qps=100000 --dataset_size=50000 --buffer_size=1024
</pre>

<a name="submit_aedk_20w_offline_power"></a>
### Power

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> time ck run cmdgen:benchmark.image-classification.qaic-loadgen --verbose \
--sut=aedk_20w --sdk=1.5.00 --model=resnet50 --scenario=offline \
--mode=performance --target_qps=100000 --dataset_size=50000 --buffer_size=1024 \
--power=yes --power_server_ip=192.168.0.3 --power_server_port=4949 --sleep_before_ck_benchmark_sec=90
</pre>

<a name="submit_aedk_20w_offline_compliance"></a>
### Compliance

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> time ck run cmdgen:benchmark.image-classification.qaic-loadgen --verbose \
--sut=aedk_20w --sdk=1.5.00 --model=resnet50 --scenario=offline \
--compliance,=TEST04-A,TEST04-B,TEST05,TEST01 --target_qps=100000 --dataset_size=50000 --buffer_size=1024
</pre>

## Info

Please contact anton@krai.ai if you have any problems or questions.
