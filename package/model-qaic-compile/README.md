# Convert ONNX models into the QAIC format

## Prerequisites

**TODO**

### ImageNet validation dataset (required for calibration)

If you have the ImageNet validation dataset e.g. in `/datasets/dataset-imagenet-ilsvrc2012-val`, you can register it with CK as follows:

```bash
$ ck detect soft:dataset.imagenet.val \
--full_path=/datasets/dataset-imagenet-ilsvrc2012-val/ILSVRC2012_val_00000001.JPEG
```

## Example:

```bash
$ ck install package --tags=qaic,resnet50-example,precision.int8
```
