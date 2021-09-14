# ImageNet Docker image

```
> $(ck find ck-qaic:docker:imagenet)/build.sh
Sending build context to Docker daemon  6.745GB
Step 1/2 : FROM centos:7
 ---> 8652b9f0cb4c
Step 2/2 : ADD imagenet /imagenet
 ---> d085ffcf869d
Successfully built d085ffcf869d
Successfully tagged imagenet:latest

real    1m49.201s
user    0m18.557s
sys     0m8.360s

Done.

> docker image ls imagenet
REPOSITORY   TAG       IMAGE ID       CREATED              SIZE
imagenet     latest    d085ffcf869d   About a minute ago   6.91GB
```

## Parameters

- `DATASETS_DIR=/local/mnt/workspace/mlcommons/datasets`
- `IMAGENET_NAME=imagenet`
- `IMAGENET_DIR=$DATASETS_DIR/$IMAGENET_NAME`

## Known issues

`DATASETS_DIR` should ideally have only one subdirectory `IMAGENET_NAME`. 
Otherwise, Docker may fail trying to suck them all in.
Need to provide a context directory explicitly.
