# ImageNet Docker image - preprocessed for ResNet50 using OpenCV 

## Build an image with the original ImageNet dataset

See [`ck-qaic:docker:imagenet`](https://github.com/krai/ck-qaic/tree/main/docker/imagenet).

## Build an image with the preprocessed ImageNet dataset

```
> $(ck find ck-qaic:docker:imagenet-preprocessed)/build.sh
Running: time docker build --build-arg GROUP_ID=981 --build-arg USER_ID=2000 -t imagenet-preprocessed:latest -f Dockerfile.centos7 .
Sending build context to Docker daemon  14.85kB
Step 1/25 : FROM imagenet:latest as builder
 ---> d085ffcf869d
...
Installation time: 540.9947526454926 sec.
Removing intermediate container d3986e55f8b9
 ---> e8b0487e0478
Step 23/25 : FROM centos:7 AS final
 ---> 8652b9f0cb4c
Step 24/25 : COPY --from=builder /home/krai/CK_TOOLS/dataset-imagenet-preprocessed-using-opencv* /imagenet-preprocessed
 ---> 73da07fc53ab
Step 25/25 : COPY --from=builder /imagenet/ILSVRC2012_val_00000001.JPEG /imagenet/ILSVRC2012_val_00000001.JPEG
 ---> cc6a4cf9ff39
Successfully built cc6a4cf9ff39
Successfully tagged imagenet-preprocessed:latest

real    17m3.147s
user    0m0.677s
sys     0m0.755s

Done.

> docker image ls imagenet-preprocessed
REPOSITORY              TAG       IMAGE ID       CREATED         SIZE
imagenet-preprocessed   latest    cc6a4cf9ff39   5 minutes ago   7.73GB
```
