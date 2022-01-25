## Initialize the Docker Setup
### On Ubuntu-20.04
`WORKSPACE=/home bash ubuntu-20.04.sh`

### On CentOS-7
`WORKSPACE=/home bash centos7.sh`

### Initialize the CK Setup (common for all OS) 
`WORKSPACE=/home bash ck_init.sh`

## Create and Launch the Benchmark docker Containers

1. [Image Classification](https://github.com/krai/ck-qaic/tree/main/docker/resnet50)
2. [Object Detection Small](https://github.com/krai/ck-qaic/tree/main/docker/ssd-mobilenet)
3. [Object Detection Large](https://github.com/krai/ck-qaic/tree/main/docker/ssd-resnet34)
4. [Language Processing](https://github.com/krai/ck-qaic/blob/main/docker/bert/README.md)
