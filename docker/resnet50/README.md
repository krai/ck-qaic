# Qualcomm Cloud AI - MLPerf ResNet50 Docker image

## Building the base CK Image

This image is independent of SDK
```
WORKSPACE_DIR=/local/mnt/workspace DOCKER_OS=ubuntu $(ck find repo:ck-qaic)/docker/build_ck.sh resnet50
```

## Building SDK-dependent Image

```
WORKSPACE_DIR=/local/mnt/workspace SDK_VER=1.7.1.12 COMPILE_PRO=yes COMPILE_STD=no DOCKER_OS=ubuntu $(ck find repo:ck-qaic)/docker/build.sh resnet50
```

### Docker Build parameters

- `SDK_VER=1.7.1.12`
- `SDK_DIR=/local/mnt/workspace/sdks`
- `WORKSPACE_DIR=/local/mnt/workspace`
- `DOCKER_OS=ubuntu` (only CentOS 7 and Ubuntu 20.04 are supported)
- `PYTHON_VER=3.9.13` (Python interpreter)
- `GCC_MAJOR_VER=11` (C++ compiler)
- `CK_VER=2.6.1` ([MLCommons Collective Knowledge](https://github.com/mlcommons/ck))
- `COMPILE_PRO=yes` (compilation for PCIe Pro server cards)
- `COMPILE_STD=no`  (compilation for PCIe Standard server cards) 
- `DEBUG_BUILD=no` (DEBUG_BUILD=yes builds a larger image with support for model compilation)

** `CLEAN_MODEL_BASE=yes` will rebuild the base CK docker container


