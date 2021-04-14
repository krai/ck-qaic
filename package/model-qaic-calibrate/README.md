

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
		--full_path=$HOME/CK-TOOLS/dataset-coco-calibration-mlperf/train2017/000000391895.jpg \
		--extra_tags=preprocessed,mlperf,calibration
    
### Examples

1. MLPerf SSD-ResNet34 ONNX with the 500 images of Coco Calibration dataset
						 
		ck install package --tags=profile,ssd_resnet34
		
### Use a Pregenerated Profile
Suppose you have the folder **AIMET_profile_download** in your $HOME, containing profile.yaml, node-precision.yaml and AIMET modified ssd_resnet34_aimet.onnx files from an AIMET run, you can detect them as follows:

	echo "vdetected" | ck detect soft:model.qaic \
	--extra_tags=ssd_resnet34 \
	--full_path=$HOME/AIMET_profile_download/profile.yaml
	--ienv._AIMET_MODEL=yes
### Generation of AIMET profile using GPUs 
Currently we are using AIMET docker image to generate the AIMET profile to be run using GPUs. 
	WORKSPACE=`pwd`
	git clone https://github.com/quic/aimet.git
	source $WORKSPACE/aimet/packaging/envsetup.sh

Follow these instructions to build the docker:

	docker_image_name="aimet-dev-docker:latest"
	docker_container_name="aimet-dev-latest"
	docker build -t ${docker_image_name} -f $WORKSPACE/aimet/Jenkins/Dockerfile .
#### Start docker container manually

	docker run --gpus all --rm -it -u $(id -u ${USER}):$(id -g ${USER}) \
	  -v /etc/passwd:/etc/passwd:ro -v /etc/group:/etc/group:ro \
	  -v ${HOME}:${HOME} -v ${WORKSPACE}:${WORKSPACE} \
	  -v "/mnt/workspace":"/mnt/workspace" \
	  --entrypoint /bin/bash -w ${WORKSPACE} --hostname aimet-dev ${docker_image_name}

#### Build code and install

Follow these instructions to build the AIMET code inside docker:

set  `WORKSPACE="<absolute_path_to_workspace>"`  **again.**

	cd $WORKSPACE 
	mkdir build && cd build
	cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON ../aimet
	make -j8 

After a successful build, install the package using the following instructions:

	cd $WORKSPACE/build
	make install

Once the installation step is complete, the AIMET package is created at  `$WORKSPACE/build/staging/universal/lib/`.

#### Setup paths

Setup the package and library paths as follows:

	export PYTHONPATH=$WORKSPACE/build/staging/universal/lib/x86_64-linux-gnu:$WORKSPACE/build/staging/universal/lib/python:$PYTHONPATH
	export LD_LIBRARY_PATH=$WORKSPACE/build/staging/universal/lib/x86_64-linux-gnu:$WORKSPACE/build/staging/universal/lib/python:$LD_LIBRARY_PATH

#### Generating AIMET-optimized model with encodings
Ensure that mlcommons/inference is installed for utilizing model definitions and preprocessing routines. You can install a local copy:

`git clone https://github.com/mlcommons/inference.git`

To export the model to onnx and generate encodings, and depending on your mlcommons/inference installation location, you will need to update your path:

	export PYTHONPATH=$PYTHONPATH:$WORKSPACE/inference/vision/classification_and_detection/python

A small few changes must be made to  `inference/vision/classification_and_detection/python/coco.py`, since it depends on "pycoco" which is no longer available (it is available as pycocotools.coco). Comment out  `import pycoco`  in the file (line 15). This package is not needed for our purposes anyways as we do not run evaluation in our script. Additionally, the reference to "val2017" (line 75) must be removed since calibration images are part of the training set, not the validation set.

Replace line 75: 
```image_name = os.path.join("val2017", img["file_name"])```
with
```image_name = os.path.join(img["file_name"])```

The onnx model and encodings will be generated by the below command, which is formatted to expose the syntax.

	python ssd_resnet_aimet.py <path/to/resnet34-ssd1200.pytorch> <path/to/calibration-annotations> <path/to/calibration-images>

The base model used in our experiments can be downloaded  [here](https://zenodo.org/record/3236545/files/resnet34-ssd1200.pytorch). The outputs are saved as "ssd_resnet34_aimet.[onnx|pth|encodings|encodings.yaml]" to a timestamped directory under the "outputs" directory. Note that the pytorch file (i.e., .pth) is used for debugging. A parameters file is also generated: "ssd_resnet34_aimet_params.pkl". You can verify the parameters of your run by executing  `python ssd_resnet34_aimet.py show-params <path/to/params-file.pkl>`.
