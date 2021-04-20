

# Profile ONNX or TF models using Glow

## Resnet50

### Prerequisites

#### ImageNet validation dataset

If you have the ImageNet validation dataset e.g. in `/datasets/dataset-imagenet-ilsvrc2012-val`, you can register it with CK as follows:

    echo "full" | ck detect soft:dataset.imagenet.val --extra_tags=full,ilsvrc2012 \
    --full_path=/datasets/dataset-imagenet-ilsvrc2012-val/ILSVRC2012_val_00000001.JPEG
#### Preprocess the Imagenet calibration dataset
Install the preprocessed dataset locally as follows:

1. Preprocess only the first 5 images of Imagenet 2012 (quick test)

		ck install package --tags=imagenet,cal,first.5
2. Preprocess the MLPerf Calibration Option 1 Dataset

		ck install package --tags=imagenet,cal,mlperf.option1 
3. **Alternatively** Preprocess the MLPerf Calibration Option 2 Dataset

		ck install package --tags=imagenet,cal,mlperf.option2 

### Examples

1. MLPerf ResNet50 TF with the first 5 images of ImageNet 2012 (quick test) 
						 
		ck install package --tags=profile,resnet50.tf,first.5
2. MLPerf ResNet50 TF with calibration option 1

		ck install package --tags=profile,resnet50.tf,mlperf.option1
3. MLPerf ResNet50 TF with calibration option 2

		ck install package --tags=profile,resnet50.tf,mlperf.option2

### Use a Pregenerated Profile
	echo "vdetected" | ck detect soft:model.qaic \
	--extra_tags=resnet50.tf \
	--full_path=$HOME/CK/ck-qaic/profile/resnet50/bs.8/profile.yaml

## SSD-Resnet34

### Prerequisites

#### Coco Train dataset

1. If you have the Coco train dataset e.g. in `/datasets/dataset-coco-2017-train`, you can register it with CK as follows:

		echo "full" | ck detect soft:dataset.coco.2017.train \
		--extra_tags=full \
		--full_path=/datasets/dataset-coco-2017-train/train2017/000000000009.jpg
2. **Alternatively** you can install the Coco dataset as follows:

		ck install package --tags=dataset,coco,train,full
#### Preprocess the Training dataset
1. Install locally

		ck install package --tags=dataset,coco,calibration,preprocessed
2. **Alternatively** you can detect an already preprocessed calibration dataset as follows

		echo "vdetected" | ck detect soft:dataset.coco.2017.train \
		--full_path=/home/arjun/CK-TOOLS/dataset-coco-calibration-mlperf/train2017/000000391895.jpg \
		--extra_tags=preprocessed,mlperf,calibration
    
### Examples

1. MLPerf SSD-ResNet34 ONNX with the 500 images of Coco Calibration dataset
						 
		ck install package --tags=profile,ssd_resnet34
	1. Using GPUs
		
			ck install package --dep_add_tags.lib-aimet=with-cuda \
			--tags=profile,ssd_resnet34 --env.CUDA_VISIBLE_DEVICES=0
		
### Use a Pregenerated Profile
Suppose you have the folder **AIMET_profile_download** in your $HOME, containing profile.yaml, node-precision.yaml and AIMET modified ssd_resnet34_aimet.onnx files from the `ck install package --tags=profile,ssd_resnet34` command (or its GPU variant) on a different machine (for example, one used for a GPU run), you can detect the profile as follows:

	echo "vdetected" | ck detect soft:compiler.glow.profile \
	--extra_tags=ssd_resnet34,gpu,aimet --full_path=$HOME/AIMET_profile_download/profile.yaml \
	--ienv._AIMET_MODEL=yes
