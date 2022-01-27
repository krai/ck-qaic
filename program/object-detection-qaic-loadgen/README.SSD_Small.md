# Qualcomm Cloud AI - MLPerf Inference - Object Detection (SSD Small)

Please refer to [Docker README](https://github.com/krai/ck-qaic/blob/main/docker/ssd-mobilenet/README.md) for a faster way to benchmark Object Detection using SSD ResNet34 model on Qualcomm Cloud AI. The below instructions are meant only when docker environment is not used. 

## Initial System Setup

Complete the common benchmarking setup as detailed [here](https://github.com/krai/ck-qaic/blob/main/program/README.md)



<a name="prepare_coco"></a>
## Prepare the COCO 2017 validation dataset (5,000 images)

### Hint
Once you have downloaded the COCO 2017 validation dataset using CK, you can register it with CK again if needed (e.g. if you reset your CK environment) as follows:
```
ck detect soft:dataset.coco.2017.val --extra_tags=detected,full \
--full_path=/datasets/dataset-coco-2017-val/val2017/000000000139.jpg
```

<a name="prepare_coco_download"></a>
###  Download

```
ck install package --ask --tags=dataset,coco,val,2017
```


<a name="prepare_coco_preprocess"></a>
### Preprocess


<a name="prepare_coco_preprocess_ssd_mobilenet"></a>
### SSD-MobileNet

```
ck install package \
--dep_add_tags.lib-python-cv2=opencv-python-headless \
--tags=dataset,object-detection,for.ssd_mobilenet.onnx.preprocessed.quantized,using-opencv,full \
--extra_tags=using-opencv
```

<a name="prepare_workload_calibrate"></a>
## Calibrate the model

The COCO 2017 training dataset takes `20G`. Use `--ask` to confirm the destination directory.

```
ck install package --ask --tags=dataset,coco,train,2017
```
```
ck install package --tags=dataset,coco,calibration,mlperf
```

```
ck install package --ask --tags=dataset,coco.2017,calibration,for.ssd_mobilenet.onnx.preprocessed
```
```
ck install package --tags=profile,ssd_mobilenet,bs.1
```
```
ck install package --tags=profile,ssd_mobilenet,bs.2
```
```
ck install package --tags=profile,ssd_mobilenet,bs.4
```



<a name="prepare_workload_compile"></a>
## Compile the workload

### Compilation for 20w AEDKs (edge category)
```
ck install package --tags=model,qaic,ssd_mobilenet,ssd_mobilenet.aedk_20w.offline
```
```
ck install package --tags=model,qaic,ssd_mobilenet,ssd_mobilenet.aedk_20w.singlestream
```
```
ck install package --tags=model,qaic,ssd_mobilenet,ssd_mobilenet.aedk_20w.multistream
```
### Compilation for 15w AEDKs (edge category)
```
ck install package --tags=model,qaic,ssd_mobilenet,ssd_mobilenet.aedk_15w.offline
```
```
ck install package --tags=model,qaic,ssd_mobilenet,ssd_mobilenet.aedk_15w.singlestream
```
```
ck install package --tags=model,qaic,ssd_mobilenet,ssd_mobilenet.aedk_15w.multistream
```
Once models are compiled for AEDKs they can be installed on to the device(s) using [this](https://github.com/krai/ck-qaic/tree/main/script/setup.aedk#hr-compile-the-models-and-copy-to-the-device) script.

### Compilation for edge category 16 NSP PCIe
```
ck install package --tags=model,qaic,ssd_mobilenet,ssd_mobilenet.pcie.16nsp.offline
```
```
ck install package --tags=model,qaic,ssd_mobilenet,ssd_mobilenet.pcie.16nsp.singlestream
```
```
ck install package --tags=model,qaic,ssd_mobilenet,ssd_mobilenet.pcie.16nsp.multistream
```


# Benchmark

## Edge Category
### R282_Z93_Q1

#### Quick Accuracy Run
```
ck run cmdgen:benchmark.object-detection-small.qaic-loadgen --verbose \
--sut=r282_z93_q1 --sdk=1.6.80 --model=ssd_mobilenet \
--mode=accuracy --scenario=offline 
```
#### Full Run
```
ck run cmdgen:benchmark.object-detection-small.qaic-loadgen --verbose \
--sut=r282_z93_q1 --sdk=1.6.80 --model=ssd_mobilenet \
--group.edge --group.closed --offline_target_qps=19360 --target_latency=3.9
```

### R282_Z93_Q5 
#### Quick Accuracy Run
```
ck run cmdgen:benchmark.object-detection-small.qaic-loadgen --verbose \
--sut=r282_z93_q5 --sdk=1.6.80 --model=ssd_mobilenet \
--mode=accuracy --scenario=offline
```
#### Full Run
```
ck run cmdgen:benchmark.object-detection-small.qaic-loadgen --verbose \
--sut=r282_z93_q5 --sdk=1.6.80 --model=ssd_mobilenet \
--group.edge --group.closed --offline_target_qps=97510 --target_latency=3.9
```

### AEDK_15W
#### Quick Accuracy Run
```
ck run cmdgen:benchmark.object-detection-small.qaic-loadgen --verbose \
--sut=aedk_15w --sdk=1.6.80 --model=ssd_mobilenet \
--mode=accuracy --scenario=offline 
```
#### Full Run
```
ck run cmdgen:benchmark.object-detection-small.qaic-loadgen --verbose \
--sut=aedk_15w --sdk=1.6.80 --model=ssd_mobilenet \
--group.edge --group.closed --offline_target_qps=3440 --target_latency=1.9
```

### AEDK_20W
#### Quick Accuracy Run
```
ck run cmdgen:benchmark.object-detection-small.qaic-loadgen --verbose \
--sut=aedk_20w --sdk=1.6.80 --model=ssd_mobilenet \
--mode=accuracy --scenario=offline
```
#### Full Run
```
ck run cmdgen:benchmark.object-detection-small.qaic-loadgen --verbose \
--sut=aedk_20w --sdk=1.6.80 --model=ssd_mobilenet \
--group.edge --group.closed --offline_target_qps=4090 --target_latency=2.0
```

<a name="info"></a>
# Further info

Please contact anton@krai.ai if you have any problems or questions.
