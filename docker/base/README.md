# Qualcomm Cloud AI - MLPerf Inference - base Docker images

## Build an SDK-independent base OS image

To build a base OS image including Python and GCC:

```
$(ck find ck-qaic:docker:base)/build.base.sh
```

### Parameters
- `DOCKER_OS=centos7` (only CentOS 7 is currently supported).
- `PYTHON_VER=3.8.12`.
- `GCC_MAJOR_VER=11`.
- `TIMEZONE=US/Central` (Austin).

### Test
```
docker run --rm krai/base.centos7
```
<details><pre>
centos-release-7-9.2009.1.el7.centos.x86_64
</pre></details>

## Build an SDK-independent common CK image

To build a base image for CK packages common to all supported MLPerf Inference benchmarks:

```
$(ck find ck-qaic:docker:base)/build.ck.sh
```

### Parameters
- `DOCKER_OS=centos7`.
- `PYTHON_VER=3.8.12`.
- `GCC_MAJOR_VER=11`.
- `CK_VER=2.6.1`.
- `GROUP_ID=1500`.
- `USER_ID=2000`.

### Test
```
docker run --rm krai/ck.common.centos7
```
<details><pre>
V2.6.1
</pre></details>

## Build an image for a given QAIC SDK

```
SDK_VER=1.6.66 SDK_DIR=/local/mnt/workspace/sdks/ $(ck find ck-qaic:docker:base)/build.qaic.sh
```

### Parameters
- `DOCKER_OS=centos7`.
- `SDK_DIR=/local/mnt/workspace/sdks/`.
- `SDK_VER=1.5.6`.
- `PLATFORM_SDK`.
- `APPS_SDK`.

### Test
```
export SDK_VER=1.6.71 && docker run --privileged --rm krai/qaic.centos7:${SDK_VER}
```
<details><pre>
        Status:Ready
</pre></details>
