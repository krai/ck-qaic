# Qualcomm Cloud AI - MLPerf Inference - base Docker images

## Build an SDK-independent Docker image

The below command will build a base image for the OS (CentOS 7 by default) which is used to build another base image for the CK packages common for all supported MLPerf Inference benchmarks.

```
$(ck find ck-qaic:docker:base)/build_ck.sh
```

### Parameters
- `DOCKER_OS=centos7`

## Build a Docker image for a given SDK

```
SDK_VER=1.5.6 SDK_DIR=/local/mnt/workspace/sdks/ $(ck find ck-qaic:docker:base)/build.sh
```

### Parameters

- `DOCKER_OS=centos7`
- `SDK_DIR=/local/mnt/workspace/sdks/`
- `SDK_VER=1.5.6`
- `PLATFORM_SDK`
- `APPS_SDK`
