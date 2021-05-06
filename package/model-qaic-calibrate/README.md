# Qualcomm Cloud AI - MLPerf Inference - Calibration

This package calibrates:
- [ResNet50](#resnet50) using the QAIC toolchain.
- [SSD-ResNet34](#ssd_resnet34) using the AI Model Efficiency Toolkit ([AIMET](https://quic.github.io/aimet-pages/index.html)).

<a name="resnet50"></a>
## Calibrate ResNet50

The ResNet50 model is calibrated using the QAIC toolchain based on
[Glow](https://github.com/pytorch/glow). This requires `500` images
randomly selected from the [ImageNet](http://www.image-net.org/) 2012 validation dataseti (`50,000` images).

<a name="resnet50_calbration_dataset"></a>
### Prepare the calibration dataset based on [MLPerf option #1](https://github.com/mlcommons/inference/blob/master/calibration/ImageNet/cal_image_list_option_1.txt)

#### Detect the ImageNet 2012 validation dataset

Unfortunately, the ImageNet validation dataset [cannot be
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

The SSD-ResNet34 model is calibrated using the AI Model Efficiency Toolkit ([AIMET](https://github.com/quic/aimet)).

<a name="ssd_resnet34_calbration_dataset"></a>
### Prepare the calibration dataset

The [official MLPerf Inference calibration dataset](https://github.com/mlcommons/inference/blob/master/calibration/COCO/coco_cal_images_list.txt)
consists of `500` images randomly selected from the [COCO](https://cocodataset.org) 2017 training dataset (`118,287` images).

#### Download the COCO training dataset

The COCO 2017 training dataset takes `20G`. Use `--ask` to confirm the destination directory.

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> ck install package --ask --tags=dataset,coco,train,2017
<b>[anton@ax530b-03-giga ~]&dollar;</b> du -hs &dollar;(ck locate env --tags=dataset,coco,train,2017)
20G    /datasets/dataset-coco-2017-train
</pre>

##### Hint

Once you have downloaded the COCO 2017 training dataset **using CK** under e.g. `/datasets/dataset-coco-2017-train`,
you can register it with CK again if needed (e.g. if you reset your CK environment) as follows:

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> ck detect soft:dataset.coco.2017.train --extra_tags=detected,full \
--full_path=/datasets/dataset-coco-2017-train/train2017/000000000009.jpg
</pre>

#### Select the calibration dataset

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> ck install package --tags=dataset,coco,calibration,mlperf
<b>[anton@ax530b-03-giga ~]&dollar;</b> du -hs &dollar;(ck locate env --tags=dataset,coco,calibration,mlperf)
86M     /home/anton/CK-TOOLS/dataset-coco-calibration-mlperf
</pre>

#### Preprocess the calibration dataset

The calibration dataset takes `8.1G` when preprocessed to the `1200x1200` resolution: use `--ask` to confirm the destination directory.

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> ck install package --ask \
--tags=dataset,coco.2017,calibration,for-ssd-resnet-onnx-preprocessed
<b>[anton@ax530b-03-giga ~]&dollar;</b> du -hs &dollar;(ck locate env --tags=dataset,coco.2017,calibration,preprocessed)
8.1G    /datasets/dataset-object-detection-preprocessed-using-opencv-calibration-coco.2017-first.500-for-ssd-resnet-onnx-preprocessed
</pre>

##### Hint

You can detect an already preprocessed calibration dataset as follows:

<pre>
<b>[arjun@ax530b-03-giga ~]&dollar;</b>	echo "vdetected" | ck detect soft:dataset.coco.2017.train \
--full_path=/home/arjun/CK-TOOLS/dataset-coco-calibration-mlperf/train2017/000000391895.jpg \
--extra_tags=preprocessed,mlperf,calibration
</pre>  


<a name="ssd_resnet34_aimet"></a>
### Install the AI Model Effiiciency Toolkit ([AIMET](https://quic.github.io/aimet-pages/index.html))

**NB:** The resulting accuracy depends on the hardware on which the model is
calibrated.  The accuracy has been observed to satisfy the MLPerf Inference
requirement (mAP &GreaterEqual; `19.80%`) when calibrating on server-class
Intel CPUs (Xeon, but not Core).  The best accuracy,
however, has been observed when calibrating on NVIDIA GPUs (mAP &GreaterEqual;
`19.85%`).

Please follow the corresponding [AIMET installation instructions](https://github.com/krai/ck-qaic/tree/main/package/lib-aimet), and then the calibration instructions below.

<a name="ssd_resnet34_calibrate"></a>
### Calibrate

<a name="ssd_resnet34_calibrate_cpu"></a>
#### CPU

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> ck install package --tags=profile,ssd_resnet34
</pre>

<a name="ssd_resnet34_calibrate_gpu"></a>
#### GPU

<pre>
<b>[anton@krai ~]&dollar;</b> ck install package --tags=profile,ssd_resnet34 \
--dep_add_tags.lib-aimet=with-cuda --env.CUDA_VISIBLE_DEVICES=0
</pre>
		
### Detect a pregenerated profile

Suppose you generate a profile using the `ck install package --tags=profile,ssd_resnet34` command (or its GPU variant) as above.

Suppose you then copy the folder containing `profile.yaml`, `node-precision.yaml` and `ssd_resnet34_aimet.onnx` files to a different machine e.g.:

<pre>
<b>[anton@krai ~]&dollar;</b> rsync -av --exclude=preprocessed --exclude=inference --exclude=__pycache__ \
&dollar;(ck locate env --tags=profile,ssd_resnet34) anton@ax530b-03-giga:~/CK-TOOLS
</pre>

Then, you can detect the profile on that machine e.g.:

<pre>
<b>[anton@ax530b-03-giga ~]&dollar;</b> echo "vdetected" | ck detect soft:compiler.glow.profile \
--ienv._AIMET_MODEL=yes --extra_tags=ssd_resnet34,aimet \
--full_path=/home/anton/CK-TOOLS/model-profile-qaic-compiler.python-3.8.5-ssd_resnet34/profile.yaml
</pre>
