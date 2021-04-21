# Qualcomm Cloud AI - MLPerf Inference - Calibration

This package calibrates the [ResNet50](#resnet50) model using the QAIC
toolchain, and the SSD-ResNet34 model using the AI Model Efficiency Toolkit
([AIMET](https://github.com/quic/aimet)).

<a name="resnet50"></a>
## Calibrate ResNet50

The ResNet50 model is calibrated using the QAIC toolchain based on
[Glow](https://github.com/pytorch/glow). It requires 500 preprocess images
randomly selected from the ImageNet 2012 validation dataset.

<a name="resnet50_calbration_dataset"></a>
### Prepare the calibration dataset based on [MLPerf option #1](https://github.com/mlcommons/inference/blob/master/calibration/ImageNet/cal_image_list_option_1.txt)

#### Detect the ImageNet validation dataset

Unfortunately, the ImageNet validation dataset (50,000 images) [cannot be
freely downloaded](https://github.com/mlcommons/inference/issues/542).  If you
have a copy of it under e.g. `/datasets/dataset-imagenet-ilsvrc2012-val/`, you
can register it with CK ("detect") by giving the absolute path to
`ILSVRC2012_val_00000001.JPEG` as follows:

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> echo "full" | ck detect soft:dataset.imagenet.val --extra_tags=ilsvrc2012,full \
--full_path=/datasets/dataset-imagenet-ilsvrc2012-val/ILSVRC2012_val_00000001.JPEG
</pre>

#### Select the calibration dataset

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> ck install package --dep_add_tags.imagenet-val=full \
--tags=dataset,imagenet,calibration,mlperf.option1
</pre>

#### Preprocess the calibration dataset

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> ck install package --dep_add_tags.dataset-source=mlperf.option1 \
--tags=dataset,preprocessed,using-opencv,for.resnet,layout.nhwc,first.500 \
--extra_tags=calibration,mlperf.option1
</pre>

### Calibrate the model

#### 8 samples per batch (for the Server and Offline scenarios)

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> ck install package --tags=profile,resnet50,mlperf.option1,bs.8
</pre>


#### 1 sample per batch (for the SingleStream scenario)

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> ck install package --tags=profile,resnet50,mlperf.option1,bs.1
</pre>


<a name="ssd_resnet34"></a>
## Calibrate SSD-ResNet34

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
