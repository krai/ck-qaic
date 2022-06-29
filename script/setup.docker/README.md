# Qualcomm Cloud AI - MLPerf Inference

## Docker setup (for Datacenter and Edge servers)

### Host OS dependent

#### Ubuntu 20.04 host
```
WORKSPACE=/local/mnt/workspace bash ubuntu-20.04.sh
```

#### CentOS 7 host
```
WORKSPACE=/local/mnt/workspace bash centos7.sh
```

### Host OS independent

#### Collective Knowledge environment
```
WORKSPACE=/local/mnt/workspace bash ck_init.sh
```

### Target OS dependent, SDK dependent

#### Create Docker images
Make sure to have copied required datasets and SDKs to `$WORKSPACE/datasets` and `$WORKSPACE/sdks`
```
DOCKER_OS=ubuntu SDK_VER=1.7.0.34 bash setup_images.sh
```

### Further info

#### Current workloads

1. [Image Classification](https://github.com/krai/ck-qaic/tree/main/docker/resnet50)
1. [Natural Language Processing](https://github.com/krai/ck-qaic/blob/main/docker/bert/README.md)

#### Deprecated workloads

1. [Object Detection Small](https://github.com/krai/ck-qaic/tree/main/docker/ssd-mobilenet)
1. [Object Detection Large](https://github.com/krai/ck-qaic/tree/main/docker/ssd-resnet34)
