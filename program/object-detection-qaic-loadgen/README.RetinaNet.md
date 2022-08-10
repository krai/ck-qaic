# Qualcomm Cloud AI - MLPerf Inference - RetinaNet

Please refer to [Docker README](https://github.com/krai/ck-qaic/tree/main/docker/retinanet/README.md) for a faster way to benchmark Object Detection using RetinaNet model on Qualcomm Cloud AI. The below instructions are meant only when docker environment is not used.

## Initial System Setup

Complete the common benchmarking setup as detailed [here](https://github.com/krai/ck-qaic/blob/main/program/README.md)


#### Install explicit dependencies via CK (also via `pip`, but register with CK at the same time)

**NB:** These dependencies are _explicit_, i.e. CK will try to satisfy them automatically. On a machine with multiple versions of Python, things can get messy, so we are playing safe here.

```
ck install package --tags=python-package,onnx,for.qaic --force_version=1.8.1 --quiet \
 && ck install package --tags=python-package,tensorflow --quiet \
 && ck install package --tags=tool,coco --quiet
```
## Download the validation dataset
```
ck install package --tags=dataset,openimages,original,validation
```

## Preprocess the validation dataset for quantized RetinaNet
```
ck pull repo:ck-env && ck install package \
--tags=dataset,preprocessed,openimages,for.retinanet.onnx.preprocessed.quantized,validation,full
```

## Prepare the RetinaNet workload
```
ck install package --tags=model,onnx,retinanet,no-nms --quiet
```

## Use precalibrated profile
```
echo "v1.8.0.73" | ck detect soft:compiler.glow.profile \
--full_path=$(ck find repo:ck-qaic)/profile/retinanet/bs.1/profile.yaml \
--extra_tags=detected,retinanet,bs.1,bs.explicit
```
### Or calibrate on your own for bs.1
```
ck install package --tags=dataset,openimages,original,calibration \
  && ck install package --tags=profile,qaic,retinanet --quiet
```

<a name="prepare_workload_compile"></a>
## Compile the workload

### Compilation for 15w AEDKs (edge category)
```
ck install package --tags=retinanet,retinanet.aedk_15w.prev.offline
```
```
ck install package --tags=retinanet,retinanet.aedk_15w.prev.singlestream
```
```
ck install package --tags=retinanet,retinanet.aedk_15w.prev.multistream
```
Once models are compiled for AEDKs they can be installed on to the device(s) using [this](https://github.com/krai/ck-qaic/tree/main/script/setup.aedk#hr-compile-the-models-and-copy-to-the-device) script.

### Compilation for PCIe Pro server cards (edge category)
```
ck install package --tags=retinanet,retinanet.pcie.16nsp.prev.offline
```
```
ck install package --tags=retinanet,retinanet.pcie.16nsp.prev.singlestream
```
```
ck install package --tags=retinanet,retinanet.pcie.16nsp.prev.multistream
```

### Compilation for PCIe Pro server cards (datacenter category)

```
ck install package --tags=retinanet,retinanet.pcie.16nsp.prev.offline
```
```
ck install package --tags=retinanet,retinanet.pcie.16nsp.prev.server
```

### Compilation for PCIe Standard server cards (edge category)
```
ck install package --tags=retinanet,retinanet.pcie.14nsp.prev.offline
```
```
ck install package --tags=retinanet,retinanet.pcie.14nsp.prev.singlestream
```
```
ck install package --tags=retinanet,retinanet.pcie.14nsp.prev.multistream
```

### Compilation for PCIe Standard server cards (datacenter category)

```
ck install package --tags=retinanet,retinanet.pcie.14nsp.prev.offline
```
```
ck install package --tags=retinanet,retinanet.pcie.14nsp.prev.server
```

## Build the MLPerf LoadGen API
```
ck compile program:object-detection-qaic-loadgen --quiet
```


## Benchmarking
For benchmarking for different System Under Tests, please see [here](https://github.com/krai/ck-qaic/blob/main/program/object-detection-qaic-loadgen/README.RetinaNet.benchmarking.md)

<a name="info"></a>
# Further info

Please contact anton@krai.ai if you have any problems or questions.
