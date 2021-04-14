
# Profile ONNX or TF models using Glow

## Resnet50

### Prerequisites

#### ImageNet validation dataset

If you have the ImageNet validation dataset e.g. in `/datasets/dataset-imagenet-ilsvrc2012-val`, you can register it with CK as follows:

    echo "full" | ck detect soft:dataset.imagenet.val --extra_tags=full,ilsvrc2012 \
    --full_path=/datasets/dataset-imagenet-ilsvrc2012-val/ILSVRC2012_val_00000001.JPEG

### Examples

1. MLPerf ResNet50 TF with the first 5 images of ImageNet 2012 (quick test) 
						 
		ck install package --tags=profile,resnet50.tf,first.5
2. MLPerf ResNet50 TF with calibration option 1

		ck install package --tags=profile,resnet50.tf,mlperf.option1
3. MLPerf ResNet50 TF with calibration option 2

		ck install package --tags=profile,resnet50.tf,mlperf.option2</pre>

### Use a Pregenerated Profile
	echo "vdetected" | ck detect soft:model.qaic,
    --extra_tags=resnet50.tf
    --full_path=$HOME/CK-TOOLS/model-qaic-converted-from-onnx-batch_size.8-resnet50/elfs/constants.bin
