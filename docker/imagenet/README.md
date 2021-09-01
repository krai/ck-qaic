# ImageNet Docker image

```
> $(ck find ck-qaic:docker:imagenet)/build.sh
Sending build context to Docker daemon  6.745GB
Step 1/2 : FROM centos:7
 ---> 8652b9f0cb4c
Step 2/2 : ADD imagenet /imagenet

 ---> 9d127fa534b7
Successfully built 9d127fa534b7
Successfully tagged imagenet:latest

Done.
```

## Parameters

- `DATASETS_DIR=/local/mnt/workspace/mlcommons/datasets`
- `IMAGENET_NAME=imagenet`
- `IMAGENET_DIR=$DATASETS_DIR/$IMAGENET_NAME`

## Known issues

`DATASETS_DIR` should ideally have only one subdirectory `IMAGENET_NAME`. 
Otherwise, Docker may fail trying to suck them all in.
Need to provide a context directory explicitly.
