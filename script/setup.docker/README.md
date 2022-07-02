# Qualcomm Cloud AI - MLPerf Inference

## Docker setup (for Datacenter and Edge servers)

### Host OS dependent

#### Ubuntu host (supported: Ubuntu 20.04)
```
WORKSPACE=/local/mnt/workspace bash setup_ubuntu.sh
```

#### CentOS host (supported: CentOS 7)
```
WORKSPACE=/local/mnt/workspace bash setup_centos.sh
```

### Host OS independent

#### Set up Collective Knowledge environment
```
WORKSPACE=/local/mnt/workspace bash setup_ck.sh
```

### Target OS dependent, SDK dependent

#### Create Docker images

**NB:** In principle, you can use any combination of the host OS and target OS e.g. Ubuntu host and CentOS target.  For simplicity, however, we recommend to use the same OS to satisfy MLPerf requirements.

**NB:** Make sure to have copied the required datasets (e.g. ImageNet) and SDKs
to `$WORKSPACE/datasets` and `$WORKSPACE/sdks`, respectively.

```
DOCKER_OS=ubuntu SDK_VER=1.7.1.12 bash setup_images.sh
```

### Further info

#### Current workloads

1. [Image Classification](https://github.com/krai/ck-qaic/tree/main/docker/resnet50)
1. [Natural Language Processing](https://github.com/krai/ck-qaic/blob/main/docker/bert/README.md)

#### Deprecated workloads

1. [Object Detection Small](https://github.com/krai/ck-qaic/tree/main/docker/ssd-mobilenet)
1. [Object Detection Large](https://github.com/krai/ck-qaic/tree/main/docker/ssd-resnet34)
