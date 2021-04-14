# Profile ONNX or TF models using Glow

## Resnet50

### Prerequisites

**TODO**

#### ImageNet validation dataset

If you have the ImageNet validation dataset e.g. in `/datasets/dataset-imagenet-ilsvrc2012-val`, you can register it with CK as follows:

<pre>
$dollar; echo "full" | ck detect soft:dataset.imagenet.val --extra_tags=full,ilsvrc2012 \
--full_path=/datasets/dataset-imagenet-ilsvrc2012-val/ILSVRC2012_val_00000001.JPEG
</pre>

### Examples

#### MLPerf ResNet50 TF with the first 5 images of ImageNet 2012 (quick test)

<pre>
$ck install package --tags=profile,resnet50.tf,first.5
</pre>


#### MLPerf ResNet50 TF with calibration option 1

<pre>
$ck install package --tags=profile,resnet50.tf,mlperf.option1
</pre>

#### MLPerf ResNet50 TF with calibration option 2

<pre>
$ck install package --tags=profile,resnet50.tf,mlperf.option2
</pre>

### Use a Pregenerated Profile
<pre>
$echo "vdetected" | ck detect soft:model.qaic,
    --extra_tags=resnet50.tf
    --full_path=$HOME/CK-TOOLS/model-qaic-converted-from-onnx-batch_size.8-resnet50/elfs/constants.bin
</pre>
