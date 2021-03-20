# Profile ONNX or TF models using Glow

## Prerequisites

**TODO**

### ImageNet validation dataset

If you have the ImageNet validation dataset e.g. in `/datasets/dataset-imagenet-ilsvrc2012-val`, you can register it with CK as follows:

<pre>
$dollar; echo "full" | ck detect soft:dataset.imagenet.val --extra_tags=full,ilsvrc2012 \
--full_path=/datasets/dataset-imagenet-ilsvrc2012-val/ILSVRC2012_val_00000001.JPEG
</pre>

## Examples

### MLPerf ResNet50 ONNX with the first 5 images of ImageNet 2012 (quick test)

<pre>
$dollar; ck install package --tags=profile,resnet50.onnx,first.5
</pre>


### MLPerf ResNet50 ONNX with calibration option 1

<pre>
$dollar; ck install package --tags=profile,resnet50.onnx,mlperf.option1
</pre>

### MLPerf ResNet50 TF with calibration option 2

<pre>
$dollar; ck install package --tags=profile,resnet50.tf,mlperf.option2
</pre>
