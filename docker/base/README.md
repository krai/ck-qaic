# Qualcomm Cloud AI - MLPerf Inference - base Docker images

## Build an SDK-independent base OS image

To build a base OS image including Python and GCC:

```
$(ck find ck-qaic:docker:base)/build.base.sh
```

### Parameters
- `DOCKER_OS=ubuntu`: only `ubuntu` (Ubuntu 20.04) and `centos` (CentOS 7) are supported.
- `PYTHON_VER=3.8.13`.
- `GCC_MAJOR_VER=11`.
- `TIMEZONE=US/Central` (Austin).

### Test

#### Ubuntu 20.04
```
docker run --rm krai/base:ubuntu_latest
```
<details><pre>
NAME="Ubuntu"
VERSION="20.04.4 LTS (Focal Fossa)"
ID=ubuntu
ID_LIKE=debian
PRETTY_NAME="Ubuntu 20.04.4 LTS"
VERSION_ID="20.04"
HOME_URL="https://www.ubuntu.com/"
SUPPORT_URL="https://help.ubuntu.com/"
BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
VERSION_CODENAME=focal
UBUNTU_CODENAME=focal
</pre></details>

#### CentOS 7

```
docker run --rm krai/base:centos_latest
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
- `DOCKER_OS=ubuntu`: only `ubuntu` (Ubuntu 20.04) and `centos` (CentOS 7) are supported.
- `PYTHON_VER=3.8.13`.
- `GCC_MAJOR_VER=11`.
- `CK_VER=2.6.1`.
- `GROUP_ID=1500`.
- `USER_ID=2000`.

### Test
```
docker run --rm krai/ck.common:ubuntu_latest
```
<details><pre>
V2.6.1
</pre></details>

## Build an image for a given QAIC SDK

```
SDK_VER=1.7.1.12 SDK_DIR=/local/mnt/workspace/sdks $(ck find ck-qaic:docker:base)/build.qaic.sh
```

### Parameters
- `DOCKER_OS=ubuntu`: only `ubuntu` (Ubuntu 20.04) and `centos` (CentOS 7) are supported.
- `SDK_DIR=/local/mnt/workspace/sdks`.
- `SDK_VER=1.7.1.12`.
- `PLATFORM_SDK`.
- `APPS_SDK`.

### Test
```
export SDK_VER=1.7.1.12 && docker run --privileged --group-add $(getent group qaic | cut -d: -f3) --rm krai/qaic:ubuntu_${SDK_VER}
```
<details><pre>
        Status:Ready
</pre></details>
