# Qualcomm Cloud AI - MLPerf base Docker image

## Build the SDK independent docker images

The below command will build a base image for the OS (centos7 by default) which is used to build another base image for the CK packages common for all MLCommons benchmarks

```
$(ck find ck-qaic:docker:base)/build_ck.sh
```
### Parameters
- `DOCKER_OS=centos7`

## Build the docker image for a given SDK
Obtain `qaic-docker-1.0.tar.gz` from Qualcomm and extract it to e.g. $HOME.

```
SDK_VER=1.5.6 SDK_DIR=/local/mnt/workspace/sdks/ $(ck find ck-qaic:docker:base)/build.sh
```

### Parameters

- `DOCKER_DIR=$HOME/qaic-docker-v1.0/`
- `DOCKER_OS=centos7`
- `SDK_DIR=/local/mnt/workspace/sdks/`
- `SDK_VER=1.5.6`
- `PLATFORM_SDK`
- `APPS_SDK`
